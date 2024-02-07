provider "aws" {
  region = var.region
}

module "tfstate_backend" {
  source                             = "cloudposse/tfstate-backend/aws"
  version                            = "1.4.0"
  terraform_backend_config_file_path = var.create_local_backend_file ? "." : ""
  terraform_backend_config_file_name = var.create_local_backend_file ? "backend.tf" : ""
  arn_format                         = var.arn_format
  s3_bucket_name                     = var.s3_bucket_name

  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["state"]

  tags = var.tags

  bucket_enabled                    = var.bucket_enabled
  dynamodb_enabled                  = var.dynamodb_enabled
  bucket_ownership_enforced_enabled = var.bucket_ownership_enforced_enabled
  force_destroy                     = var.force_destroy
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  bucket = "zarf-s3-driver"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
