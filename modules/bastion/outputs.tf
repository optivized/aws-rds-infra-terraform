output "bastion_id" {
  value       = aws_instance.bastion.id
  description = "EC2 instance ID for bastion"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of bastion"
}

output "bastion_private_ip" {
  value       = aws_instance.bastion.private_ip
  description = "Private IP of bastion"
}
