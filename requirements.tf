terraform {
  required_version = ">=1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.21"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["/home/rredziak/training/terraform/.aws/credentials"]
  profile                  = "rredziak-tf"

  region = var.region
}
