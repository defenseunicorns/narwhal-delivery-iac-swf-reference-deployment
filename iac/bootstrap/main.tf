provider "aws" {
  region = var.region
}

data "aws_partition" "current" {}

resource "random_id" "default" {
  byte_length = 2
}

locals {
  terraform_backend_config_file_path_prefix = "${path.module}/../env/${var.stage}/backends"
  terraform_backend_iac_root_path           = "${path.module}/.."
  arn_format                                = "arn:${data.aws_partition.current.partition}"
  backends                                  = ["bootstrap", "swf"]

  # naming
  prefix = var.prefix != "" ? var.prefix : join("-", [var.namespace, var.stage, var.name])
  suffix = var.suffix != "" ? var.suffix : lower(random_id.default.hex)
  # use provided name, else use generated name
  backend_s3_bucket_name      = var.backend_s3_bucket_name != "" ? var.backend_s3_bucket_name : "${local.prefix}-tfstate-${local.suffix}"
  backend_dynamodb_table_name = var.backend_dynamodb_table_name != "" ? var.backend_dynamodb_table_name : "${local.prefix}-tfstate-${local.suffix}"

  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      GithubRepo   = "github.com/defenseunicorns/narwhal-delivery-iac-swf-reference-deployment"
    }
  )
}

module "tfstate_backend" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=tags/1.4.0"
  terraform_backend_config_file_path = "" # this needs to be set to empty string to prevent this module from creating a backend.tf config file
  arn_format                         = local.arn_format

  tags = local.tags

  bucket_enabled      = true
  dynamodb_enabled    = true
  s3_bucket_name      = local.backend_s3_bucket_name
  dynamodb_table_name = local.backend_dynamodb_table_name

  bucket_ownership_enforced_enabled = var.bucket_ownership_enforced_enabled
  force_destroy                     = var.force_destroy
}

resource "local_file" "backend_config" {
  for_each = toset(local.backends)

  content = templatefile(var.terraform_backend_config_template_file, {
    region         = var.region
    bucket         = local.backend_s3_bucket_name
    key            = "${each.key}/${var.terraform_state_file}"
    dynamodb_table = local.backend_dynamodb_table_name
    profile        = var.profile
    encrypt        = true
  })
  filename = "${local.terraform_backend_config_file_path_prefix}/${each.key}-backend.tfconfig"
}

resource "local_file" "backend_tf_template" {
  for_each = toset(local.backends)

  content  = file(var.terraform_backend_tf_template_file)
  filename = "${local.terraform_backend_iac_root_path}/${each.key}/backend.tf"
}
