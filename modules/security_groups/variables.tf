variable "name" {
  description = "Environment name (staging/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where SGs will be created"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
