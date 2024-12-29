terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws,
      ]
    }
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  tags = merge(
    {
      "Name" = "${var.project_name}-cluster"
    },
    var.tags
  )
}

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count
  force_new_deployment = true

  # デプロイ関連のパラメータを直接設定
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

    # この設定を追加
  deployment_controller {
    type = "ECS"
  }

    # トリガーを追加して強制的な更新を促す
  triggers = {
    desired_count = var.desired_count
    image_version = var.image_version
    force_redeploy = timestamp()
  }

    # サービスの状態変更を待つ
  wait_for_steady_state = true

  enable_ecs_managed_tags = true
  propagate_tags  = "SERVICE"
  tags = merge(
    {
      "Name" = "${var.project_name}-service",
      "tag_propagate" = "True"
    },
    var.tags
  )
  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_tasks.id]
  }

  lifecycle {
    create_before_destroy = true
        ignore_changes = [
      # timestampによるトリガーの変更を無視
      triggers["force_redeploy"],
    ]
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  tags = merge(
    {
      "Name" = "${var.project_name}-task"
    },
    var.tags
  )
  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = "${var.repository_url}:${var.image_version}"
      environment = [
        {
          name  = "INDEX_HTML_HASH"
          value = var.image_version
        }
      ]
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = "${var.project_name}-ecs-tasks-sg"
    },
    var.tags
  )
}