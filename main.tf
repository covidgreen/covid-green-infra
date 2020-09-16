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

# SMS provider
# Will use this if SMS via SNS is enabled
provider "aws" {
  alias   = "sms"
  region  = var.sms_region
  profile = var.profile
}

# #########################################
# Data
# #########################################
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
