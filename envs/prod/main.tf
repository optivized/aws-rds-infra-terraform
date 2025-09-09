module "vpc" {
  source          = "../../modules/vpc"

  # Logical name prefix for resource naming
  name            = "prod"

  # VPC CIDR range
  vpc_cidr        = "10.0.0.0/16"

  # Public subnets — used for bastions, ALBs, NAT gateways, etc.
  public_subnets  = ["10.0.5.0/24", "10.0.6.0/24"]

  # Private subnets — used for RDS, app servers, etc.
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24"]

  # AZ mapping — must align with subnet index positions
  azs             = ["us-east-1a", "us-east-1b"]

  # Standardized tags for better visibility in AWS console
  tags = {
    Environment = "prod"
    Project     = "myproject"
    Owner       = "team-devops"
    ManagedBy   = "terraform"
  }
}
############### SECURITY GROUPS ##########################
module "security_groups" {
  source            = "../../modules/security_groups"
  name              = "prod"
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = ["YOUR-IP/32"]

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

####################### BASTION HOST##############################
module "bastion" {
  source            = "../../modules/bastion"
  name              = "prod"
  ami_id            = "ami-020cba7c55df1f615" # Replace with Amazon Linux 2 AMI ID for your region
  instance_type     = "c7i-flex.large"
  key_name          = "prod-bastion-key" # Replace with your key name
  public_subnet_ids = module.vpc.public_subnet_ids
  bastion_sg_id     = module.security_groups.bastion_sg_id

  tags = {
    Environment = "prod"
    Project     = "aws-rds"
    ManagedBy   = "terraform"
  }
}


#################### RDS MYSQL ############################
module "rds" {
  source            = "../../modules/rds"
  name              = "prod"
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
    Environment = "prod"
    Project     = "aws-rds"
    ManagedBy   = "terraform"
  }
}

