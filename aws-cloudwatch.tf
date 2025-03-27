resource "aws_iam_role_policy_attachment" "webapp-cloudwatch-policy-attachment" {
  role       = aws_iam_role.aws-bucket-file-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}