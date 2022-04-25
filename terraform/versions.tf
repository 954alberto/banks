terraform {
  required_version = ">= 1.1.9"
  backend "s3" {
    bucket         = "terraform-state-763886000561"
    key            = "lambda/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
    }
  }
}
