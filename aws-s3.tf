resource "random_uuid" "aws-s3-bucket-name" {}

resource "aws_iam_role" "aws-bucket-file-role" {
  name = "fileBucketS3Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" },
      },
    ]
  })
}

resource "aws_iam_policy" "aws-bucket-file-policy" {
  name        = "fileBucketS3Policy"
  description = "policy for s3 bucket for v1/file endpoint in healthz application"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.aws-healthz-file-bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.aws-healthz-file-bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws-s3-bucket-policy-attach" {
  role       = aws_iam_role.aws-bucket-file-role.name
  policy_arn = aws_iam_policy.aws-bucket-file-policy.arn
}

resource "aws_s3_bucket" "aws-healthz-file-bucket" {
  bucket        = random_uuid.aws-s3-bucket-name.result
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws-s3-server-side-encrypt-config" {
  bucket = aws_s3_bucket.aws-healthz-file-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-bucket-ownership" {
  bucket = aws_s3_bucket.aws-healthz-file-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.s3-bucket-ownership]

  bucket = aws_s3_bucket.aws-healthz-file-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.aws-healthz-file-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-bucket-lifecycle" {
  bucket = aws_s3_bucket.aws-healthz-file-bucket.id

  rule {
    id     = "TransitionToStandardIA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

