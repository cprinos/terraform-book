provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket ="cjpzip-terraform-up-and-running-state"

    versioning { 
        enabled = true
    }

    lifecycle { 
        prevent_destroy = true
    }
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.terraform_state.arn}"
}


terraform {
  backend "s3" {
    bucket = "cjpzip-terraform-up-and-running-state"
    key    = "tf_bucket_state"
    region = "us-east-1"
    encrypt = true
  }
}