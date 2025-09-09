terraform {
  backend "s3" {
    bucket         = "abhanan-v1-terraform-state-staging"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-staging"
    encrypt        = true
  }
}
