# check for available zones incremantally

data "aws_availability_zones" "available" {
  state = "available"
}