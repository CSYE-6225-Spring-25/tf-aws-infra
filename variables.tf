# configure region

variable "vpc_region_aws" {
  description = "provide a region to create a aws vpc"
  type        = string
  default     = "us-east-1"
}

# configure vpc name

variable "vpc_name_aws" {
  description = "provide a name for your vpc"
  type        = string
  default     = "healthz-vpc"
}

# configure cidr range

variable "vpc_cidr_aws" {
  description = "provide ip range for vpc"
  type        = string
  default     = "172.16.0.0/16"
}

# configure number of private subnets

variable "vpc_subnet_count_aws" {
  description = "Provide the number of public and private subnets required"
  type        = number
  default     = 3
}


