variable "name" {
  description = "Environment name (staging/prod)"
  type        = string
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "master_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "max_connections" {
  description = "Custom MySQL parameter max_connections"
  type        = string
  default     = "150"
}

variable "backup_retention_days" {
  description = "Number of days to keep backups"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

