terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "pgr301-terraform-state"
    key    = "kandidat-23/infra-s3/terraform.tfstate"
    region = "eu-west-1"
  }
}
