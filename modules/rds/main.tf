###########################################
# RDS Parameter Group
###########################################
resource "aws_db_parameter_group" "this" {
  name        = "${var.name}-mysql-pg"
  family      = "mysql8.0"
  description = "Parameter group for ${var.name} MySQL RDS"

  # Custom parameters
  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-pg"
  })
}

###########################################
# MySQL RDS Instance
###########################################
resource "aws_db_instance" "this" {
  identifier              = "${var.name}-mysql"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.rds_sg_id]
  username                = var.master_username
  password                = var.master_password
  parameter_group_name    = aws_db_parameter_group.this.name
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  auto_minor_version_upgrade = true
  backup_retention_period = var.backup_retention_days

  tags = merge(var.tags, {
    Name = "${var.name}-mysql"
  })
}

###########################################
# DB Subnet Group
###########################################
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-mysql-subnets"
  subnet_ids = var.private_subnet_ids
  description = "Subnet group for ${var.name} MySQL RDS"

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-subnets"
  })
}

