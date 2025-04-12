resource "random_password" "db_password" {
  length  = 16
  special = false
}


# Create a Secrets Manager secret with a unique name.
resource "aws_secretsmanager_secret" "rds-db-password" {
  name_prefix = "rds-db-password-" # Changed name to avoid conflict with a secret scheduled for deletion.
  description = "RDS database password"
  kms_key_id  = aws_kms_key.secrets-kms-key.arn
}

# Store the generated password into the secret.
resource "aws_secretsmanager_secret_version" "rds-db-password-version" {
  secret_id = aws_secretsmanager_secret.rds-db-password.id
  secret_string = jsonencode({
    password = random_password.db_password.result
  })
}

# IAM policy allowing access to KMS and Secrets Manager
resource "aws_iam_policy" "kms-secret-access" {
  name = "kmsAndSecretManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM policy to the role 
resource "aws_iam_role_policy_attachment" "kms-secret-manager-attach-policy" {
  role       = aws_iam_role.aws-bucket-file-role.name
  policy_arn = aws_iam_policy.kms-secret-access.arn
}
