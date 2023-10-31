provider "aws" {
  region = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "jomacs-terraform-projects"
    key    = "layer2/terraform.tfstate"
    region = "us-east-2"
  }
}