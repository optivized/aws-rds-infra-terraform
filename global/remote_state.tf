# global/remote_state.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "abhanan-v1-terraform-state-${var.env_name}"
  acl    = "private"

  versioning {
    enabled = true
  }


  tags = {
    Name        = "TerraformState-${var.env_name}"
    Environment = var.env_name
    Project     = "myproject"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${var.env_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "TerraformLocks-${var.env_name}"
    Environment = var.env_name
    Project     = "rds-setup"
  }
}

