module "vpc" {
  source          = "../../modules/vpc"

  # Logical name prefix for resource naming
  name            = "staging"

  # VPC CIDR range
  vpc_cidr        = "10.0.0.0/16"

  # Public subnets — used for bastions, ALBs, NAT gateways, etc.
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  # Private subnets — used for RDS, app servers, etc.
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  # AZ mapping — must align with subnet index positions
  azs             = ["us-east-1a", "us-east-1b"]

  # Standardized tags for better visibility in AWS console
  tags = {
    Environment = "staging"
    Project     = "myproject"
    Owner       = "team-devops"
    ManagedBy   = "terraform"
  }
}
############### SECURITY GROUPS ##########################
module "security_groups" {
  source            = "../../modules/security_groups"
  name              = "staging"
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = ["165.1.166.228/32"]

  tags = {
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}

####################### BASTION HOST##############################
module "bastion" {
  source            = "../../modules/bastion"
  name              = "staging"
  ami_id            = "ami-020cba7c55df1f615" # Replace with Amazon Linux 2 AMI ID for your region
  instance_type     = "c7i-flex.large"
  key_name          = "staging-bastion-key" # Replace with your key name
  public_subnet_ids = module.vpc.public_subnet_ids
  bastion_sg_id     = module.security_groups.bastion_sg_id

  tags = {
    Environment = "staging"
    Project     = "aws-rds"
    ManagedBy   = "terraform"
  }
}


#################### RDS MYSQL ############################
module "rds" {
  source            = "../../modules/rds"
  name              = "staging"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id         = module.security_groups.rds_sg_id
  master_username   = "admin"
  master_password   = "SuperSecretPassword123!"
  max_connections   = "150"
  backup_retention_days = 7

  tags = {
    Environment = "staging"
    Project     = "aws-rds"
    ManagedBy   = "terraform"
  }
}

