provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "cjpzip-terraform-up-and-running-state"
    key    = "stage/data-stores/mysql"
    region = "us-east-1"
    encrypt = true
  }
}