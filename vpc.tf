# configure vpc

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_aws
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name_aws
  }
}

# configure internet gateway

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name_aws}-igw"
  }
}


