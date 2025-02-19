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

# configure aws profile

variable "vpc_profile_aws" {
  description = "Enter aws profile"
  type        = string
  default     = "dev"
}

#  configure subnet mask

variable "vpc_subnet_mask_aws" {
  description = "please enter a value, mask sum of this value and cidr mask should not exceed 28 and accomadate all subnets"
  type        = number
  default     = 4
}


