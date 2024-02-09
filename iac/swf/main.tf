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
  prefix = join("-", [var.namespace, var.stage, var.name])
  suffix = lower(random_id.default.hex)

  vpc_name                   = "${local.prefix}-${local.suffix}"
  cluster_name               = "${local.prefix}-${local.suffix}"
  bastion_name               = "${local.prefix}-bastion-${local.suffix}"
  access_logging_name_prefix = "${local.prefix}-accesslog-${local.suffix}"
  kms_key_alias_name_prefix  = "alias/${local.prefix}-${local.suffix}"
  access_log_sqs_queue_name  = "${local.prefix}-accesslog-access-${local.suffix}"
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      GithubRepo   = "github.com/defenseunicorns/narwhal-delivery-iac-swf-reference-deployment"
    }
  )
}
