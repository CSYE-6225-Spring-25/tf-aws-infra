# resource "aws_instance" "app_instance" {
#   ami           = var.custom_ami
#   instance_type = var.aws_instance_type
#
#   iam_instance_profile = aws_iam_instance_profile.file_bucket_instance_profile.name
#   subnet_id            = aws_subnet.public[0].id
#
#   # Attach the application security group
#   vpc_security_group_ids = [
#     aws_security_group.application.id
#   ]
#
#   # Disable termination protection
#   disable_api_termination = false
#
#   # Configure the root EBS volume using variables
#   root_block_device {
#     volume_size           = var.root_volume_size
#     volume_type           = var.root_volume_type
#     delete_on_termination = var.delete_on_termination
#   }
#
#   user_data = templatefile("./script/user-data-script.sh", {
#     DB_HOST            = substr(aws_db_instance.aws-rds-instance.endpoint, 0, length(aws_db_instance.aws-rds-instance.endpoint) - 5)
#     DB_USERNAME        = var.db_username
#     DB_PASSWORD        = var.db_password
#     DB_NAME            = var.db_name
#     PORT               = var.app_port
#     AWS_S3_BUCKET_NAME = aws_s3_bucket.aws-healthz-file-bucket.bucket
#     AWS_REGION         = var.vpc_region_aws
#     ENVIRONMENT        = var.env_webapp
#   })
#
#   tags = {
#     Name = "AppInstance"
#   }
# }

resource "aws_kms_key" "ec2-kms-key" {
  description             = "KMS key for EC2 EBS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90


  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // 1. Allow the account root full management of the key.
      {
        "Sid" : "AllowRootAccountToManageKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      // 1b. Allow the Terraform caller (or current identity) to update the key policy.
      {
        "Sid" : "AllowTerraformCallerToManageKeyPolicy",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${data.aws_caller_identity.current.arn}"
        },
        "Action" : [
          "kms:PutKeyPolicy",
          "kms:GetKeyPolicy",
          "kms:DeleteKeyPolicy"
        ],
        "Resource" : "*"
      },
      // 2. Allow EC2 instance role access.
      {
        "Sid" : "AllowEC2InstanceRoleAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.aws-bucket-file-role.name}"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      // 3. Allow EC2 service principal.
      {
        "Sid" : "AllowEC2Service",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      // 4. Allow Secrets Manager.
      {
        "Sid" : "AllowSecretsManagerServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "secretsmanager.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      // 5. Allow RDS service.
      {
        "Sid" : "AllowRDSServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      // 6. Allow S3 service.
      {
        "Sid" : "AllowS3ServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      // 7. Allow Terraform user (demo-user).
      {
        "Sid" : "AllowTerraformUserToUseKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/demo-user"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      // 8. Allow Auto Scaling service principal.
      {
        "Sid" : "AllowAutoScalingService",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "autoscaling.amazonaws.com"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      // 9. Allow Service-Linked Role for Auto Scaling.
      {
        "Sid" : "AllowServiceLinkedRoleAutoScaling",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_kms_alias" "ec2-kms-key-alias" {
  name          = "alias/ec2-key-terraform"
  target_key_id = aws_kms_key.ec2-kms-key.key_id
}

resource "aws_launch_template" "csye6225_asg" {
  name   = "webapp-launch-template"
  image_id      = var.custom_ami
  instance_type = var.aws_instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.file_bucket_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    # subnet_id                   = aws_subnet.public[*].id
    security_groups = [aws_security_group.application.id]
  }

  user_data = base64encode(templatefile("./script/user-data-script.sh", {
    DB_HOST            = substr(aws_db_instance.aws-rds-instance.endpoint, 0, length(aws_db_instance.aws-rds-instance.endpoint) - 5)
    DB_USERNAME        = var.db_username
    DB_NAME            = var.db_name
    PORT               = var.app_port
    AWS_S3_BUCKET_NAME = aws_s3_bucket.aws-healthz-file-bucket.bucket
    AWS_REGION         = var.vpc_region_aws
    ENVIRONMENT        = var.env_webapp
    SECRET_MANAGER     = aws_secretsmanager_secret.rds-db-password.id
  }))

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2-kms-key.arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-webapp-instance"
    }
  }
}
