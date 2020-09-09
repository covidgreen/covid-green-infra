# #########################################
# Backend config
# #########################################
terraform {
  required_version = ">= 0.12.29, < 0.14"

  # Leaving this, even though we have moved towards using this repo as a module - will ignore in that case
  # Also need to cater for git submodule/subtree usage for existing infrastructure
  backend "s3" {}

  # Providers
  required_providers {
    archive = "~> 1.3.0"
    aws     = "~> 2.70"
    null    = "~> 2.1"
    random  = "~> 2.0"
  }
}

# #########################################
# AWS providers
# #########################################
# Main provider
provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

# Provider based on main but using us_east_1 as region
# Will use this if creating a TLS certificate in us-east-1 region as required by CloudFront Edge used by the APIGateway
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.profile
}

# DNS provider
# Will use this if managing DNS, in some cases the Route53 zones are managed on a different account
provider "aws" {
  alias   = "dns"
  region  = var.aws_region
  profile = var.dns_profile
}


# #########################################
# Data
# #########################################
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
