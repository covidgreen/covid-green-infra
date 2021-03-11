terraform {
  required_version = ">= 0.12.29, < 0.14"

  # Leaving this, even though we have moved towards using this repo as a module - will ignore in that case
  # Also need to cater for git submodule/subtree usage for existing infrastructure
  backend "s3" {}

  # Providers
  required_providers {
    archive = "~> 1.3.0"
    aws     = "~> 3.31"
    null    = "~> 2.1"
    random  = "~> 3.0.0"
    # dns     = "~> 2.1.0"
  }
}
