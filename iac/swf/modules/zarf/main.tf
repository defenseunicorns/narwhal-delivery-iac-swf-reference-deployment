
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}


resource "aws_kms_key" "default" {
  description             = "kms key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_access.json
  tags                    = local.tags
  multi_region            = true
}

# Create custom policy for KMS
data "aws_iam_policy_document" "kms_access" {
  # checkov:skip=CKV_AWS_111: todo reduce perms on key
  # checkov:skip=CKV_AWS_109: todo be more specific with resources
  # checkov:skip=CKV_AWS_356: todo be more specific with kms resources
  statement {
    sid = "KMS Key Default"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}::iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*",
    ]

    resources = ["*"]
  }
  statement {
    sid = "CloudWatchLogsEncryption"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = ["*"]
  }
  statement {
    sid = "Cloudtrail KMS permissions"
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",   # Allows reading objects from the bucket
      "s3:PutObject",   # Allows uploading objects to the bucket
      "s3:DeleteObject" # Allows deleting objects from the bucket
    ]

    resources = [
      "${local.arn_format}:s3:::${local.zarf_s3_bucket_name}",
      "${local.arn_format}:s3:::${local.zarf_s3_bucket_name}/*" # objects within the bucket as well
    ]
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  force_destroy = false
  bucket        = local.s3_bucket_name

  tags = {
    Name        = var.s3_bucket
    Environment = var.stage
  }

  # Bucket policies
  attach_policy                            = true
  policy                                   = data.aws_iam_policy_document.bucket_policy.json
  attach_deny_insecure_transport_policy    = true
  attach_require_latest_tls_policy         = true
  attach_deny_incorrect_encryption_headers = true
  attach_deny_incorrect_kms_key_sse        = true
  allowed_kms_key_arn                      = aws_kms_key.default.arn
  attach_deny_unencrypted_object_uploads   = true

  # S3 Bucket Ownership Controls
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  acl = "private" # "acl" conflicts with "grant" and "owner"

  versioning = {
    status     = var.s3_bucket_versioning_enabled
    mfa_delete = var.bucket_mfa_delete
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.default.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = var.bucket_lifecycle_rule
}


module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v3.8.2"

  create_bucket = var.create_s3_bucket

  bucket        = var.s3_bucket_name_use_prefix ? null : local.s3_bucket_name
  bucket_prefix = var.s3_bucket_name_use_prefix ? local.s3_bucket_name_prefix : null

  attach_policy = var.attach_bucket_policy
  policy        = local.bucket_policy

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
