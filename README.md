# AWS Infrastructure Setup using Terraform

# 

This repository contains Terraform code to set up AWS infrastructure, including:

- **VPC** (public & private subnets, NAT, route tables)
- **Bastion Host** for SSH access
- **MySQL RDS** instance with parameter group management
- **Remote state management** using **S3** + **DynamoDB**
- Separate environments: **staging** and **production**

This guide explains the **step-by-step process** to deploy the infrastructure.

---

## **📌 Prerequisites**

Before starting, make sure you have:

- An **AWS Account** with required permissions
- Terraform installed
- AWS CLI configured
- A valid **AWS key pair** for SSH access
- MySQL client installed locally **or** on the bastion host

---

## **🚀 Setup Steps**

### **Step 1 — Clone the Repository**

```bash
git clone https://github.com/your-org/aws-infra-terraform.git
cd aws-infra-terraform

```

---

### **Step 2 — Go to the Global Directory**

The **global** directory manages **S3 buckets** and **DynamoDB tables** used for Terraform remote state.

```bash
cd aws-infra-terraform/global

```

### **2.1 Update Remote State Configuration**

- Open **`remote_state.tf`**
- Update the **S3 bucket name prefix** and **DynamoDB table name** according to your project.

Example:

```hcl
bucket         = "myproject-terraform-state"
dynamodb_table = "myproject-terraform-lock"

```

---

### **Step 3 — Create Remote State Resources**

Run the following commands to create **S3 buckets** and **DynamoDB tables** for each environment:

```bash
terraform init
terraform apply -var="env_name=staging" -state=staging.tfstate
terraform apply -var="env_name=prod" -state=prod.tfstate

```

This will:

- Create an **S3 bucket** for storing Terraform state
- Create a **DynamoDB table** for Terraform **state locking**

---

### **Step 4 — Generate & Configure SSH Key Pair**

Before deploying environments, create an AWS key pair for accessing the bastion host.

### **4.1 Create Key Pair**

```bash
aws ec2 create-key-pair --key-name myproject-key --query "KeyMaterial" --output text > myproject-key.pem
chmod 400 myproject-key.pem

```

---

### **Step 5 — Deploy Staging Environment**

Navigate to the **staging** directory:

```bash
cd ../staging

```

### **5.1 Update Backend Configuration**

- Open **`backend.tf`**
- Update the **S3 bucket**, **DynamoDB table**, and **key names** to match the resources created in **Step 3**

### **5.2 Update Configuration (Staging)**

- Open **`main.tf`** inside the **staging** directory
- Update the SSH key name:

```hcl
key_name = "myproject-key"

```

### **5.3 Configure Bastion Host Access**

- In **`main.tf`**, update `allowed_ssh_cidrs` to allow SSH access from **your IP**:

```hcl
allowed_ssh_cidrs = ["<YOUR_PUBLIC_IP>/32"]

```

### **5.4 Initialize & Apply Staging Environment**

```bash
terraform init
terraform plan
terraform apply

```

Once successful, the **staging environment** will be ready.

---

### **Step 6 — Deploy Production Environment**

Now repeat the process for **prod**:

```bash
cd ../prod

```

### **6.1 Update Backend Configuration**

- Open **`backend.tf`**
- Update the **S3 bucket**, **DynamoDB table**, and **state file name** accordingly.

### **6.2 Update Configuration (Production)**

- Open **`main.tf`** inside the **prod** directory
- Update the SSH key name again:

```hcl
key_name = "myproject-key"

```

### **6.3 Configure Bastion Host Access**

- In **`main.tf`**, update `allowed_ssh_cidrs` to include your **current IP**.

### **6.4 Initialize & Apply Production Environment**

```bash
terraform init
terraform plan
terraform apply

```

Your **production environment** is now ready.

---

### **Step 7 — Access the Bastion Host**

After applying Terraform, connect to the bastion host:

```bash
ssh -i myproject-key.pem ec2-user@<BASTION_PUBLIC_IP>

```

---

### **Step 8 — Connect to RDS MySQL**

Once inside the bastion host, install the MySQL client if required:

```bash
sudo yum install -y mysql

```

Connect to your RDS instance:

```bash
mysql -h <RDS_ENDPOINT> -u <DB_USERNAME> -p

```

---

## **🛠️ Directory Structure**

```
ws-infra-terraform/
├── README.md
├── envs
│   ├── prod
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── staging
│       ├── backend.tf
│       ├── main.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── global
│   ├── prod.tfvars
│   ├── remote_state.tf
│   ├── staging.tfvars
│   └── variables.tf
└── modules
    ├── bastion
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── rds
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── security_groups
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc
        ├── main.tf
        ├── outputs.tf
        └── variables.tf

```

---

## **✅ Verification Checklist**

- [ ]  S3 + DynamoDB created successfully
- [ ]  SSH key configured in **staging** and **prod**
- [ ]  Bastion host accessible via SSH
- [ ]  RDS MySQL accessible from bastion
- [ ]  Parameter groups configured correctly

---

## **📌 Next Steps**

After completing the basic setup, future enhancements may include:

- Multi-AZ RDS setup
- RDS automated backups
- Private subnet endpoints
- Secrets Manager integration
