## REMOVE THESE AFTER APPLIES ON ALL ENVS
## We keep this to allow the transition to be made in the state file, if we renamed the plan would balk indicating a missing provider
provider "aws" {
  version = "2.68.0"
  alias   = "us"
  region  = "us-east-1"
  profile = var.profile
}

provider "aws" {
  version = "2.68.0"
  alias   = "root"
  region  = var.aws_region
  profile = var.dns_profile
}
