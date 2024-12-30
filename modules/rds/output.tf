# modules/rds/outputs.tf

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_address" {
  description = "The RDS instance address"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "The RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.main.identifier
}

output "db_security_group_id" {
  description = "The security group ID associated with the RDS instance"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_id" {
  description = "The DB subnet group ID"
  value       = aws_db_subnet_group.main.id
}

output "db_parameter_group_id" {
  description = "The DB parameter group ID"
  value       = aws_db_parameter_group.main.id
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_password" {
  description = "The master password for the database"
  value       = aws_db_instance.main.password
  sensitive   = true
}