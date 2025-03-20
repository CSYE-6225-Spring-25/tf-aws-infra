resource "aws_instance" "app_instance" {
  ami           = var.custom_ami
  instance_type = var.aws_instance_type


  subnet_id = aws_subnet.public[0].id

  # Attach the application security group
  vpc_security_group_ids = [
    aws_security_group.application.id
  ]

  # Disable termination protection
  disable_api_termination = false

  # Configure the root EBS volume using variables
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.delete_on_termination
  }

  user_data = templatefile("./script/user-data-script.sh", {
    DB_HOST            = substr(aws_db_instance.aws-rds-instance.endpoint, 0, length(aws_db_instance.aws-rds-instance.endpoint) - 5)
    DB_USERNAME        = var.db_username
    DB_PASSWORD        = var.db_password
    DB_NAME            = var.db_name
    PORT               = var.app_port
    AWS_S3_BUCKET_NAME = aws_s3_bucket.aws-healthz-file-bucket.bucket
    AWS_REGION         = var.vpc_region_aws
    AWS_ACCESS_KEY     = var.aws_access_key_id
    AWS_SA_KEY         = var.aws_secret_access_key
  })


  tags = {
    Name = "AppInstance"
  }
}
