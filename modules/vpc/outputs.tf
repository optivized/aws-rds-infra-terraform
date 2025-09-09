output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet ids"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet ids"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway ids (one per AZ/public subnet)"
  value       = aws_nat_gateway.this[*].id
}

output "public_route_table_id" {
  description = "Public route table id"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table ids (one per private subnet)"
  value       = aws_route_table.private[*].id
}

