output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "Bastion SG ID"
}

output "rds_sg_id" {
  value       = aws_security_group.rds.id
  description = "RDS SG ID"
}
