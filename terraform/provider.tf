terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "terraform-state-file-store-mms"
    key = "nginx_docker.tf.state"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}