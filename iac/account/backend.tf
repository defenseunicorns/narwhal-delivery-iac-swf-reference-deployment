terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "us-gov-west-1"
    bucket  = "du-test-narwhal-delivery-iac-swf-state"
    key     = "terraform.tfstate"
    profile = ""
    encrypt = "true"

    dynamodb_table = "du-test-narwhal-delivery-iac-swf-state-lock"
  }
}
