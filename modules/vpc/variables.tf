variable "name" {
  description = "Logical name for the VPC (prefix for resources)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets (one per AZ)"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets (one per AZ)"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones to use (must match subnet lengths)"
  type        = list(string)
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

# validate lengths to help avoid misconfiguration
# require public_subnets, private_subnets and azs to have same length

