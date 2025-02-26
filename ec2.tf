resource "aws_instance" "app_instance" {
  ami           = var.custom_ami
  instance_type = "t2.micro"


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

  tags = {
    Name = "AppInstance"
  }
}
