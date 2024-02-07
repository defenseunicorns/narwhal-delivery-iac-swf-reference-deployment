terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region         = "us-gov-west-1"
    bucket         = "narwhal-delivery-iac-swf"
    key            = "terraform.tfstate"
    dynamodb_table = "narwhal-delivery-iac-swf-terraform-state-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
