data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

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
  prefix = var.prefix != "" ? var.prefix : join("-", [var.namespace, var.stage, var.name])
  suffix = var.suffix != "" ? var.suffix : lower(random_id.default.hex)

  # naming, be aware of character limits
  vpc_name                   = join("-", [local.prefix, local.suffix])
  cluster_name               = join("-", [local.prefix, local.suffix])
  bastion_name               = join("-", [local.prefix, "bastion", local.suffix])
  access_logging_name_prefix = join("-", [local.prefix, "accesslog", local.suffix])
  kms_key_alias_name_prefix  = "alias/${join("-", [local.prefix, local.suffix])}"
  access_log_sqs_queue_name  = join("-", [local.prefix, "accesslog", "access", local.suffix])
  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      GithubRepo   = "github.com/defenseunicorns/narwhal-delivery-iac-swf-reference-deployment"
    }
  )
}
