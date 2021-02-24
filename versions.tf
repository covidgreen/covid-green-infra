terraform {
  required_version = ">= 0.13"

  # Leaving this, even though we have moved towards using this repo as a module - will ignore in that case
  # Also need to cater for git submodule/subtree usage for existing infrastructure
  backend "s3" {}

  # Providers
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 1.3.0"
    }
    #aws     = "~> 2.70"
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.10"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.0"
    }
  }
}
