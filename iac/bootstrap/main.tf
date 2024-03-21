provider "aws" {
  region = var.region
}

data "aws_partition" "current" {}

resource "random_id" "default" {
  byte_length = 2
}

locals {
  terraform_backend_config_file_path_prefix = "${path.module}/../env/${var.stage}/backends"
  terraform_env_file_path_prefix            = "${path.module}/../env/${var.stage}/tfvars"
  terraform_backend_iac_root_path           = "${path.module}/.."
  arn_format                                = "arn:${data.aws_partition.current.partition}"

  # If 'var.prefix' is explicitly null, allow it to be empty
  # If 'var.prefix' is an empty string, generate a prefix
  # If 'var.prefix' is neither null nor an empty string, assign the value of 'var.prefix' itself
  prefix = var.prefix == null ? "" : (
    var.prefix == "" ? join("-", compact([var.namespace, var.stage, var.name])) :
    var.prefix
  )

  # If 'var.suffix' is null, assign an empty string
  # If 'var.suffix' is an empty string, assign a randomly generated hexadecimal value
  # If 'var.suffix' is neither null nor an empty string, assign the value of 'var.suffix' itself
  suffix = var.suffix == null ? "" : (
    var.suffix == "" ? lower(random_id.default.hex) :
    var.suffix
  )

  # use provided name, else use generated name
  backend_s3_bucket_name      = var.backend_s3_bucket_name != "" ? var.backend_s3_bucket_name : join("-", compact([local.prefix, var.tfstate_backend_name, local.suffix]))
  backend_dynamodb_table_name = var.backend_dynamodb_table_name != "" ? var.backend_dynamodb_table_name : join("-", compact([local.prefix, var.tfstate_backend_name, local.suffix]))

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
  for_each = toset(var.backends)

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
  for_each = toset(var.backends)

  content  = file(var.terraform_backend_tf_template_file)
  filename = "${local.terraform_backend_iac_root_path}/${each.key}/backend.tf"
}

resource "local_file" "context_tfvars_template" {
  count = var.create_context_tfvars ? 1 : 0
  content = templatefile(var.terraform_context_tfvars_template_file, {
    var_prefix                  = var.prefix # determines if the prefix is explicitly set to null
    var_suffix                  = var.suffix
    local_prefix                = local.prefix # use local if var is not explicitly set to null
    local_suffix                = local.suffix
    terraform_state_bucket_name = local.backend_s3_bucket_name
  })
  filename = "${local.terraform_env_file_path_prefix}/context.tfvars"
}
