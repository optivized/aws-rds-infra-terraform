# AWS RDS Terraform Project

This Terraform project deploys **VPC, Bastion Host, Security Groups, and MySQL/PostgreSQL RDS instances** in AWS.  
It supports **multiple environments** (staging, prod) and uses **remote state with S3 and DynamoDB** for safe collaboration.  
RDS instances are **private**, accessible only via Bastion host.

---

## **Directory Structure**

aws-infra-terraform/
├── modules/
│ ├── vpc/ # VPC, subnets, IGW, NAT, route tables
│ ├── security_groups/ # Security groups for bastion & RDS
│ ├── bastion/ # EC2 bastion host module
│ └── rds/ # RDS MySQL/PostgreSQL module
├── envs/
│ ├── staging/
│ │ ├── main.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ └── prod/
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
├── global/ # S3 bucket & DynamoDB for remote state
└── README.md

markdown
Copy code

---

## **Prerequisites**

1. Terraform v1.5+ installed.
2. AWS CLI installed and configured.
3. SSH key pair for Bastion host.
4. AWS IAM user with permissions for:
   - VPC, EC2, RDS, S3, DynamoDB.
5. Internet access for Terraform providers.

---

## **Step 0 — Bootstrap Global State**

The `global` directory creates **S3 bucket** for Terraform state and **DynamoDB table** for state locking.

**Files:**

- `variables.tf` → contains `env_name` variable.  
- `staging.tfvars` / `prod.tfvars` → set `env_name` per environment.  
- `remote_state.tf` → defines S3 bucket & DynamoDB table.  

**Example usage:**

```bash
cd global

# Bootstrap staging environment
terraform init
terraform apply -var="env_name=staging" -state=staging.tfstate

# Bootstrap prod environment
terraform apply -var="env_name=prod" -state=prod.tfstate
This will create separate S3 buckets and DynamoDB tables for staging and prod.

Step 1 — Configure Environment Backend
In each environment (envs/staging / envs/prod), configure Terraform to use remote state:

hcl
Copy code
terraform {
  backend "s3" {
    bucket         = "abhanan-v1-terraform-state-${var.env_name}"
    key            = "${var.env_name}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-${var.env_name}"
    encrypt        = true
  }
}
Then run:

bash
Copy code
cd envs/staging
terraform init -var="env_name=staging"
This migrates your local state to S3 with state locking.

Step 2 — Deploy Resources
Select environment:

bash
Copy code
cd envs/staging  # or envs/prod
Initialize Terraform:

bash
Copy code
terraform init
Plan deployment:

bash
Copy code
terraform plan -out plan.tfplan -var-file=../../global/staging.tfvars
Apply deployment:

bash
Copy code
terraform apply plan.tfplan
Resources deployed:

VPC with public & private subnets

Internet Gateway & NAT Gateways

Security Groups for Bastion & RDS

Bastion EC2 host

RDS instance with parameter group

Step 3 — Access RDS via Bastion
SSH into Bastion host:

bash
Copy code
ssh -i ~/.ssh/<your-key>.pem ec2-user@<bastion_public_ip>
Connect to RDS:

bash
Copy code
mysql -h <rds_endpoint> -u admin -p
RDS is private, accessible only through Bastion.

Step 4 — Outputs
After terraform apply, Terraform will output:

Bastion Public IP

RDS Endpoint

RDS Parameter Group Name

Step 5 — Destroy Resources
bash
Copy code
terraform destroy -var-file=../../global/staging.tfvars
Always ensure you are in the correct environment.

Best Practices
Use Terraform modules for reusable resources.

Keep sensitive variables (master_password) outside code.

Use remote backend with S3 + DynamoDB.

Always plan before applying.

Use separate .tfvars per environment.

Limit RDS access via Bastion host only.

Enable versioning on S3 bucket to prevent accidental state loss.

Next Enhancements
Multi-AZ RDS for HA

Read replicas

Automated failover handling

Backup lifecycle & retention

Monitoring with CloudWatch alerts

Support / Contacts
DevOps Lead: devops@example.com

AWS Account Owner: aws-admin@example.com

yaml
Copy code

---

This version is **ready for a new person**:

- Explains **global bootstrap with `-state`**.  
- Explains **remote backend configuration**.  
- Includes full **environment deployment steps**.  
- Covers **Bastion access**, **outputs**, **destroy**, **best practices**, and future enhancements.  

---

If you want, I can also create **ready-to-use `.tfvars` templates** for staging and prod that a new user can just fill in and run everything.  

Do you want me to create them?







