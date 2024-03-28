locals {
  velero_kms_key_alias_name_prefix = join("-", compact([local.prefix, var.velero_kms_key_alias, local.suffix]))
}

module "velero_s3_bucket" {
  for_each = toset(var.velero_bucket_names)

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v4.1.0"

  bucket        = join("-", compact([local.prefix, each.key, local.suffix]))
  force_destroy = var.velero_s3_bucket_force_destroy
  tags          = local.tags

  versioning = {
    status = "Enabled"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.velero_kms_key.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "velero_s3_bucket" {
  for_each = toset(var.velero_bucket_names)

  bucket = join("-", compact([local.prefix, each.key, local.suffix]))

  rule {
    id = join("-", compact([local.prefix, each.key, "version-retention", local.suffix]))

    filter {}

    noncurrent_version_expiration {
      newer_noncurrent_versions = 5
      noncurrent_days           = 90
    }

    noncurrent_version_transition {
      newer_noncurrent_versions = 2
      storage_class   = "GLACIER_IR"
    }

    status = "Enabled"
  }
}

module "velero_kms_key" {
  source = "github.com/defenseunicorns/terraform-aws-uds-kms?ref=v0.0.2"

  kms_key_alias_name_prefix = local.velero_kms_key_alias_name_prefix
  kms_key_deletion_window   = 7
  kms_key_description       = "Velero Key"
}

module "velero_irsa_s3" {
  source = "./modules/irsa-s3"

  stage                = var.stage
  serviceaccount_names = var.velero_service_account_names
  policy_name          = "velero"
  prefix               = local.prefix
  suffix               = local.suffix
  k8s_namespace        = var.velero_namespace
  bucket_names         = var.velero_bucket_names
  kms_key_arn          = module.velero_kms_key.kms_key_arn
  oidc_provider_arn    = module.eks.oidc_provider_arn
}
