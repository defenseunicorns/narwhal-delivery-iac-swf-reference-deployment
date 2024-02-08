provider "aws" {
  region = var.region
}

module "tfstate_backend" {
  source                             = "cloudposse/tfstate-backend/aws"
  version                            = "1.4.0"
  terraform_backend_config_file_path = var.create_local_backend_file ? "." : ""
  terraform_backend_config_file_name = var.create_local_backend_file ? "backend.tf" : ""
  arn_format                         = var.arn_format
  #s3_bucket_name                     = var.s3_bucket_name

  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = ["state"]
  terraform_state_file = "account/terraform.tfstate"

  tags = var.tags

  bucket_enabled                    = true
  dynamodb_enabled                  = true
  bucket_ownership_enforced_enabled = var.bucket_ownership_enforced_enabled
  force_destroy                     = var.force_destroy
}

resource "aws_kms_key" "default" {
  description             = "kms key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_access.json
  tags                    = var.tags
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
        "${var.arn_format}:iam::${data.aws_caller_identity.current.account_id}:root"
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
      "${var.arn_format}:s3:::zarf-s3-storage-driver",
      "${var.arn_format}:s3:::zarf-s3-storage-driver/*" # objects within the bucket as well
    ]
  }
}

data "aws_caller_identity" "current" {}

module "zarf_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  force_destroy = false
  bucket        = "zarf-s3-storage-driver"

  tags = {
    Name        = "zarf-s3-storage-driver"
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

  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  # block_public_acls       = true
  # block_public_policy     = true
  # ignore_public_acls      = true
  # restrict_public_buckets = true

  # S3 Bucket Ownership Controls
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  acl = "private" # "acl" conflicts with "grant" and "owner"

  versioning = {
    status     = true
    mfa_delete = var.zarf_bucket_mfa_delete
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.default.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = var.zarf_bucket_lifecycle_rules

}
