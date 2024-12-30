# modules/rds/variables.tf

variable "project_name" {
  type        = string
  description = "Project name to be used for resource naming"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for RDS DB subnet group"
}

variable "engine" {
  type        = string
  description = "Database engine type"
  default     = "mysql"
}

variable "engine_version" {
  type        = string
  description = "Database engine version"
  default     = "8.0"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage size in GB"
  default     = 20
}

variable "identifier" {
  type        = string
  description = "Name of the database to create"
}

variable "master_username" {
  type        = string
  description = "Master username for the database"
}

variable "master_password" {
  type        = string
  description = "Master password for the database"
}

variable "multi_az" {
  type        = bool
  description = "Enable multi-AZ deployment"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "Preferred backup window"
  default     = "00:00-01:00"  # バックアップ時間帯を0時から1時に変更
}

variable "maintenance_window" {
  type        = string
  description = "Preferred maintenance window"
  default     = "Mon:02:00-Mon:03:00"  # メンテナンス時間帯を2時から3時に変更
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 4510
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security group ID of the ECS tasks"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
  default     = {}
}