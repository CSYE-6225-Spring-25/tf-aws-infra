# tf-aws-infra

## Overview
This project automates the creation of AWS networking infrastructure using Terraform. It sets up a Virtual Private Cloud (VPC) with public and private subnets across multiple availability zones, along with essential networking resources such as route tables and an Internet Gateway.

## Prerequisites
Ensure the following are installed and configured before running Terraform:

- [AWS CLI](https://aws.amazon.com/cli/) (Authenticated with AWS credentials)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- An AWS account with appropriate IAM permissions

## AWS Networking Setup
Terraform will provision the following resources:

1. **Virtual Private Cloud (VPC)**
2. **Public and Private Subnets** (3 public and 3 private, distributed across availability zones)
3. **Internet Gateway (IGW)** attached to the VPC
4. **Public Route Table** linked to public subnets
5. **Private Route Table** linked to private subnets
6. **Routes:**
   - Public route for internet access (0.0.0.0/0 via IGW)
   - Private route for internal communication

## Installation & Usage

### 1. Configure AWS CLI
Ensure your AWS CLI is configured with valid credentials:
```sh
aws configure --profile <profile name>
```

### 2. Initialize Terraform
Run the following command to initialize Terraform and download required providers:
```sh
terraform init
```

### 3. Plan Deployment
Generate an execution plan to preview the resources Terraform will create:
```sh
terraform plan
```

### 4. Apply Terraform Configuration
Deploy the infrastructure using:
```sh
terraform apply -auto-approve
```

### 5. Verify Resources
Once deployment is complete, verify the created resources using AWS:

### 6. Destroy Resources
To delete all resources created by Terraform, run:
```sh
terraform destroy -auto-approve
```

## Best Practices
- Avoid hardcoding values in Terraform files; use variables.
- Implement remote state storage (e.g., S3 + DynamoDB) to manage Terraform state effectively.
- Follow the principle of least privilege when assigning IAM permissions.

## License
This project is licensed under the MIT License.

---

Happy automating with Terraform! 🚀

