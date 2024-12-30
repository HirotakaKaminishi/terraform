# モジュールの呼び出し
module "vpc" {
  source = "../../modules/vpc"
  providers = {
    aws = aws
  }

  project_name         = "my-ecs-project"
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["ap-northeast-1a", "ap-northeast-1c"]
}

module "ecs" {
  source = "../../modules/ecs"
  providers = {
    aws = aws
  }

  project_name         = "my-ecs-project"
  task_cpu             = 256
  task_memory          = 512
  container_name       = "my-app"
  container_image      = module.ecr.repository_url
  image_version        = module.ecr.image_version
  repository_url       = module.ecr.repository_url
  container_port       = 80
  desired_count        = 1
  force_new_deployment = true
  subnet_ids           = module.vpc.public_subnet_ids

  # RDS関連の設定
  rds_security_group_id = module.rds.db_security_group_id
  db_host               = "localhost.localstack.cloud" # LocalStack用
  db_name               = "module.rds.db_instance_name"
  db_user               = module.rds.db_username
  db_password           = module.rds.db_password
  db_port               = module.rds.db_instance_port

  # その他の設定
  tags = {
    "Project" = "my-ecs-project"
  }
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  vpc_id                = module.vpc.vpc_id
}

module "alb" {
  source = "../../modules/alb"
  providers = {
    aws = aws
  }

  project_name   = "my-ecs-project"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  container_port = 80
  tags = {
    "Project" = "my-ecs-project"
  }
}

module "ecr" {
  source = "../../modules/ecr"
  providers = {
    aws = aws
  }

  project_name = "my-ecs-project"
  region       = "ap-northeast-1"
  tags = {
    "Project" = "my-ecs-project"
  }
}

module "rds" {
  source = "../../modules/rds"
  providers = {
    aws = aws
  }

  project_name          = "my-ecs-project"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  identifier            = module.rds.db_instance_name
  master_username       = "admin"
  master_password       = "4Ernfb7E1"
  ecs_security_group_id = module.ecs.ecs_security_group_id

  tags = {
    "Project" = "my-ecs-project"
  }
}