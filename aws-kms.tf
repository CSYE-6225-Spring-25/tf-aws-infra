data "aws_caller_identity" "current" {}

resource "aws_kms_key" "secrets-kms-key" {
  description             = "kms key for secret manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = aws_kms_key.ec2-kms-key.policy
}

resource "aws_kms_alias" "secrets-kms-key-alias" {
  name          = "alias/secrets-key-terraform"
  target_key_id = aws_kms_key.secrets-kms-key.key_id
}