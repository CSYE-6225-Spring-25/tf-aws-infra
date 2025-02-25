# configure cidr range for each subnets

locals {
  public_cidr_subnets  = [for i in range(var.vpc_subnet_count_aws) : cidrsubnet(var.vpc_cidr_aws, var.vpc_subnet_mask_aws, i)]
  private_cidr_subnets = [for i in range(var.vpc_subnet_count_aws) : cidrsubnet(var.vpc_cidr_aws, var.vpc_subnet_mask_aws, i + var.vpc_subnet_count_aws)]
}

# public subnets

resource "aws_subnet" "public" {
  count                   =     length(local.public_cidr_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_cidr_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name_aws}-public-${count.index}"
  }
}

# private subnets

resource "aws_subnet" "private" {
  count                   = length(local.private_cidr_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_cidr_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name_aws}-private-${count.index}"
  }
}

# public route table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name_aws}-pub-route-table"
  }
}

# public route

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_gw.id
}

# public route table association

resource "aws_route_table_association" "pub-rt-association" {
  count          = length(local.public_cidr_subnets)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public[count.index].id
}

# private route table

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name_aws}-pvt-route-table"
  }
}

# private route table association

resource "aws_route_table_association" "pvt_rt_association" {
  count          = length(local.private_cidr_subnets)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private[count.index].id
}
