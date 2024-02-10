
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "random_id" "default" {
  byte_length = 2
}


locals {
  prefix = join("-", [var.namespace, var.stage, var.name])
  suffix = var.suffix != "" ? var.suffix : lower(random_id.default.hex)

  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      GithubRepo   = "github.com/defenseunicorns/narwhal-delivery-iac-swf-reference-deployment"
    }
  )
}

################################################################################
# KMS Key
################################################################################
# just make this to reduce complexity for now

locals {
  key_statements = jsonencode({
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals = [
      {
        type        = "AWS"
        identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
    ]
  })
}

resource "aws_kms_key" "default" {
  description             = "kms key"
  deletion_window_in_days = 7
  policy                  = local.key_statements
  enable_key_rotation     = true
  tags                    = local.tags
  multi_region            = true
}

################################################################################
# S3 Bucket
################################################################################

locals {
  s3_bucket_name        = try(coalesce(var.s3_bucket_name, "${local.prefix}-${local.suffix}"), null)
  s3_bucket_name_prefix = try(coalesce(var.s3_bucket_name_prefix, "${local.prefix}-"), null)

  # local.kms_master_key_id sets KMS encryption: uses custom config if provided, else defaults to module's key or specified kms_key_id, and is null if encryption is disabled.
  kms_master_key_id = aws_kms_key.default.arn
  default_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = local.kms_master_key_id
      }
    }
  }

  s3_bucket_server_side_encryption_configuration = var.enable_s3_bucket_server_side_encryption_configuration ? coalesce(var.s3_bucket_server_side_encryption_configuration, local.default_encryption_configuration) : null
}

module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v4.1.0"

  create_bucket = var.create_s3_bucket

  bucket        = var.s3_bucket_name_use_prefix ? null : local.s3_bucket_name
  bucket_prefix = var.s3_bucket_name_use_prefix ? local.s3_bucket_name_prefix : null

  # attach_policy = var.attach_bucket_policy
  # policy        = local.bucket_policy

  attach_public_policy                 = var.attach_public_bucket_policy
  block_public_acls                    = var.block_public_acls
  block_public_policy                  = var.block_public_policy
  ignore_public_acls                   = var.ignore_public_acls
  restrict_public_buckets              = var.restrict_public_buckets
  versioning                           = var.s3_bucket_versioning
  server_side_encryption_configuration = local.s3_bucket_server_side_encryption_configuration
  lifecycle_rule                       = var.s3_bucket_lifecycle_rules
  force_destroy                        = var.s3_bucket_force_destroy

  tags = var.tags
}

################################################################################
# IRSA
################################################################################

locals {
  zarf_irsa_policy_name = "${local.prefix}-irsa-policy-${local.suffix}"
  zarf_irsa_role_name   = "${local.prefix}-irsa-role-${local.suffix}"
}
module "zarf_irsa_policy" {
  count = var.create_irsa_role ? 1 : 0

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.34.0"

  name        = local.zarf_irsa_policy_name
  path        = "/"
  description = "Access to s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",   # Allows reading objects from the bucket
          "s3:PutObject",   # Allows uploading objects to the bucket
          "s3:DeleteObject" # Allows deleting objects from the bucket
        ]
        Resource = module.s3_bucket.s3_bucket_arn
      }
    ]
  })

}

module "zarf_irsa_role" {
  count = var.create_irsa_role ? 1 : 0

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=v5.34.0"

  role_name = local.zarf_irsa_role_name

  role_policy_arns = {
    policy = module.zarf_irsa_policy[0].arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["zarf:docker-registry-sa"]
    }
  }
}
