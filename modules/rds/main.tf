terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

# RDSインスタンスの作成
resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db"
  engine           = var.engine
  engine_version   = var.engine_version
  instance_class   = var.instance_class
  allocated_storage = var.allocated_storage
  username         = var.master_username
  password         = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  apply_immediately      = true
  parameter_group_name = aws_db_parameter_group.main.name
  tags = merge(
    {
      "Name" = "${var.project_name}-db"
    },
    var.tags
  )
}

# DBサブネットグループの作成
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    {
      "Name" = "${var.project_name}-db-subnet-group"
    },
    var.tags
  )
}

# セキュリティグループの作成
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [var.ecs_security_group_id]
    cidr_blocks     = ["0.0.0.0/0"] 
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    {
      "Name" = "${var.project_name}-rds-sg"
    },
    var.tags
  )
}

# パラメータグループの作成
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-db-params"
  family = "${var.engine}${split(".", var.engine_version)[0]}"
  
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "default_authentication_plugin"
    value = "mysql_native_password"
  }
  
  tags = merge(
    {
      "Name" = "${var.project_name}-db-params"
    },
    var.tags
  )
}