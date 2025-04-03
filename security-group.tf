resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from any IP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from any IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "load-balancer-security-group"
  }
}

#ec2 instance security grouup
resource "aws_security_group" "application" {
  name        = "application-security-group"
  description = "Security group for web application EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    description     = "Allow application-specific traffic"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application-security-group"
  }
}

#rds database instance security group

resource "aws_security_group" "rds-security-group" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  } # allowing incoming connection from EC2 instance security group

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  tags = {
    Name = "rds-security-group"
  }
}
