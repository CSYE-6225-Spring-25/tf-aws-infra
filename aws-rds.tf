resource "aws_kms_key" "rds-kms-key" {
  description             = "KMS key for RDS storage encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = aws_kms_key.ec2-kms-key.policy
}

resource "aws_kms_alias" "rds-kms-key-alias" {
  name          = "alias/rds-key-terraform"
  target_key_id = aws_kms_key.rds-kms-key.key_id
}

# parameter group for rds 
resource "aws_db_parameter_group" "parameter-group-psql" {
  name        = "csye6225-psql-parameter-group"
  family      = "postgres16"
  description = "DB Parameter Group for webapp"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "csye6225-psql-parameter-group"
  }
}

#assign private subnet to rds
resource "aws_db_subnet_group" "rds-private-subnet" {
  name       = "csye6225-rds-private-subnet"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "csye6225-rds-private-subnet"
  }
}

resource "aws_iam_service_linked_role" "aws-rds-role" {
  aws_service_name = "rds.amazonaws.com"
  description      = "Service-linked role for RDS"
}

resource "aws_db_instance" "aws-rds-instance" {
  allocated_storage      = 20
  instance_class         = "db.t3.micro"
  engine                 = "postgres"
  engine_version         = "16"
  identifier             = "csye6225"
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds-kms-key.arn
  parameter_group_name   = aws_db_parameter_group.parameter-group-psql.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds-security-group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-private-subnet.name # Using DB Subnet Group
  multi_az               = false

  tags = {
    Name = "csye6225"
  }
  depends_on = [aws_iam_service_linked_role.aws-rds-role]
}

