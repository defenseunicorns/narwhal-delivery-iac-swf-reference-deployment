module "tfstate_backend" {
  source                                 = "cloudposse/tfstate-backend/aws"
  version                                = "1.4.0"
  terraform_backend_config_template_file = "../templates/backend.tf.tpl"
  terraform_backend_config_file_path     = var.create_local_backend_file ? "." : ""
  terraform_backend_config_file_name     = var.create_local_backend_file ? "backend.tf" : ""
  arn_format                             = var.arn_format

  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  terraform_state_file = var.terraform_state_file

  tags = var.tags

  bucket_enabled                    = var.bucket_enabled
  dynamodb_enabled                  = var.dynamodb_enabled
  bucket_ownership_enforced_enabled = var.bucket_ownership_enforced_enabled
  force_destroy                     = var.force_destroy
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${var.cluster_version}-x86_64-*"]
  }
}

resource "random_id" "default" {
  byte_length = 2
}

locals {
  name_prefix = join("-", [var.namespace, var.stage, var.name])
  name_suffix = lower(random_id.default.hex)

  vpc_name                   = "${local.name_prefix}-${local.name_suffix}"
  cluster_name               = "${local.name_prefix}-${local.name_suffix}"
  bastion_name               = "${local.name_prefix}-bastion-${local.name_suffix}"
  access_logging_name_prefix = "${local.name_prefix}-accesslog-${local.name_suffix}"
  kms_key_alias_name_prefix  = "alias/${local.name_prefix}-${local.name_suffix}"
  access_log_sqs_queue_name  = "${local.name_prefix}-accesslog-access-${local.name_suffix}"
  zarf_s3_bucket_name        = var.zarf_s3_bucket_name != "" ? var.zarf_s3_bucket_name : "${local.name_prefix}-zarf-docker-registry-${local.name_suffix}"
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      GithubRepo   = "github.com/defenseunicorns/narwhal-delivery-iac-swf-reference-deployment"
    }
  )
}
