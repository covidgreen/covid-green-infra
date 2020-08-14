## REMOVE THESE AFTER APPLIES ON ALL ENVS
## We keep this to allow the transition to be made in the state file, if we renamed the plan would balk indicating a missing provider
provider "aws" {
  alias   = "us"
  region  = "us-east-1"
  profile = var.profile
}

provider "aws" {
  alias   = "root"
  region  = var.aws_region
  profile = var.dns_profile
}

## We keep this till we have applied all the way to prod and state files are updated
provider "template" {
  version = "~> 2.1"
}
