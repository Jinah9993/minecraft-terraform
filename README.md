# Minecraft Server Terraform Infrastructure

Infrastructure as Code (IaC) for managing Minecraft server on AWS using Terraform.

## 📋 Overview

This Terraform project manages the following AWS resources:

- **EC2 Instance**: t3.small instance running Minecraft server
- **Security Group**: Firewall rules for SSH (22) and Minecraft (25565)
- **EBS Volume**: 30GB gp3 storage with data persistence

## 🏗️ Architecture

```
VPC (vpc-0e8dd6366e267a29e)
  └── Subnet (subnet-02ac0d20ae48728e9)
      └── EC2 Instance (t3.small)
          ├── Security Group (launch-wizard-1)
          │   ├── Ingress: SSH (22)
          │   └── Ingress: Minecraft (25565)
          └── EBS Volume (30GB gp3)
              └── delete_on_termination: false (data protection)
```

## 📁 Project Structure

```
minecraft-terraform/
├── main.tf              # Main infrastructure resources
├── variables.tf         # Variable definitions
├── outputs.tf           # Output values
├── terraform.tfvars     # Actual values (DO NOT commit to Git)
├── .gitignore          # Git ignore patterns
└── README.md           # This file
```

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS account with appropriate permissions

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/YOUR_USERNAME/minecraft-terraform.git
cd minecraft-terraform
```

**2. Create `terraform.tfvars` file**

```hcl
aws_region    = "us-west-2"
aws_profile   = "personal"
vpc_id        = "vpc-xxxxxxxxx"
subnet_id     = "subnet-xxxxxxxxx"
ami_id        = "ami-xxxxxxxxx"
instance_type = "t3.small"
key_name      = "your-key-name"
volume_size   = 30
volume_type   = "gp3"
instance_name = "minecraft-server"
```

**3. Initialize Terraform**

```bash
terraform init
```

**4. Preview changes**

```bash
terraform plan
```

**5. Apply configuration**

```bash
terraform apply
```

## 📝 File Descriptions

### main.tf

Contains the main infrastructure resources:

**Terraform Block**: Specifies required providers and versions

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Provider Block**: Configures AWS provider with region and profile

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

**Security Group**: Defines firewall rules

- Port 22 (SSH) for server management
- Port 25565 (Minecraft) for game connections
- All outbound traffic allowed

**EC2 Instance**: Defines compute resource

- Uses variables for flexibility
- References Security Group by ID
- `delete_on_termination = false` protects data from accidental deletion

### variables.tf

Defines all input variables with:

- `description`: Explains the variable's purpose
- `type`: Specifies data type (string, number, etc.)
- `default`: Provides default value (optional)

### terraform.tfvars

Contains actual values for variables. **Never commit this file to Git** as it may contain sensitive information.

### outputs.tf

Defines output values displayed after `terraform apply`:

- `instance_id`: EC2 instance ID
- `public_ip`: Public IP address
- `security_group_id`: Security Group ID

## 🔧 Common Operations

### View Current State

```bash
# List all managed resources
terraform state list

# Show detailed resource information
terraform state show aws_instance.minecraft

# Display all state information
terraform show
```

### Modify Infrastructure

**1. Change instance type**

Edit `terraform.tfvars`:

```hcl
instance_type = "t3.medium"
```

Then apply:

```bash
terraform plan
terraform apply
```

**2. Add new security group rule**

Edit `main.tf`:

```hcl
ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

Then apply:

```bash
terraform plan
terraform apply
```

### Import Existing Resources

```bash
# Import existing EC2 instance
terraform import aws_instance.minecraft i-xxxxxxxxx

# Import existing Security Group
terraform import aws_security_group.minecraft sg-xxxxxxxxx

# Verify import
terraform plan
```

### Destroy Infrastructure

```bash
# Destroy all resources (⚠️ CAUTION: This will delete everything)
terraform destroy

# Destroy specific resource only
terraform destroy -target=aws_instance.minecraft
```

## 🔐 Security Notes

### Files to NEVER Commit

The `.gitignore` file excludes:

- `*.tfvars` - Contains sensitive values
- `*.tfstate*` - Contains sensitive state information
- `.terraform/` - Provider binaries (auto-downloaded)
- `.terraform.lock.hcl` - Lock file (team decision)

### Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Review changes carefully**
3. **Keep state file secure** (consider S3 backend for team collaboration)
4. **Use separate AWS accounts/profiles for different environments**
5. **Tag resources appropriately for cost tracking**

## 🛠️ Troubleshooting

### Error: "Resource already exists"

**Solution**: Import the existing resource

```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

### Error: "Error acquiring the state lock"

**Solution**: Force unlock (use with caution)

```bash
terraform force-unlock <LOCK_ID>
```

### Plan shows unexpected changes

**Solution**: Check actual AWS configuration and adjust code to match

```bash
terraform show  # View current state
# Adjust code to match actual configuration
```

### Import creates differences in plan

**Solution**: Adjust code to match existing resource configuration

1. Import resource
2. Run `terraform plan` to see differences
3. Modify code to eliminate differences
4. Run `terraform plan` again to verify
5. Run `terraform apply` when no changes shown

## 📚 Key Concepts

### Infrastructure as Code (IaC)

Managing infrastructure using code instead of manual configuration:

- **Version Control**: Track changes over time
- **Reproducibility**: Recreate identical environments
- **Automation**: Reduce human error
- **Documentation**: Code serves as documentation

### Terraform Workflow

```
Write Code → Init → Plan → Apply → Commit
     ↑                                 |
     └─────────── Iterate ─────────────┘
```

### State Management

Terraform tracks infrastructure state in `terraform.tfstate`:

- Contains current infrastructure configuration
- Used to calculate changes during `plan`
- Must be protected and backed up
- Consider S3 backend for team collaboration

### Resource Dependencies

Terraform automatically handles dependencies:

```hcl
# Security Group created first
resource "aws_security_group" "minecraft" { }

# EC2 references Security Group (implicit dependency)
resource "aws_instance" "minecraft" {
  vpc_security_group_ids = [aws_security_group.minecraft.id]
}
```

## 🔄 Next Steps

Potential improvements for this infrastructure:

1. Add S3 bucket for backups
2. Add Lambda functions for auto start/stop
3. Add EventBridge rules for scheduling
4. Add IAM roles and policies
5. Implement monitoring with CloudWatch
6. Move state to S3 backend
7. Create reusable modules
8. Add multiple environments (dev, staging, prod)

## 📖 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 📄 License

This project is for personal/educational use.

---

**Note**: This infrastructure was created by importing existing AWS resources. Server configuration inside EC2 (Minecraft installation, screen sessions, etc.) is managed separately and not included in this Terraform code.
