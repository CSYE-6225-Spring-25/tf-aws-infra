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


resource "aws_launch_template" "csye6225_asg" {
  name_prefix   = "webapp-launch-template-"
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
    DB_PASSWORD        = var.db_password
    DB_NAME            = var.db_name
    PORT               = var.app_port
    AWS_S3_BUCKET_NAME = aws_s3_bucket.aws-healthz-file-bucket.bucket
    AWS_REGION         = var.vpc_region_aws
    ENVIRONMENT        = var.env_webapp
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
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-webapp-instance"
    }
  }
}
