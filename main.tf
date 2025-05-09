terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.vpc_region_aws
  profile = var.vpc_profile_aws
}