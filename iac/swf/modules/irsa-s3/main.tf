
data "aws_partition" "current" {}

resource "random_id" "default" {
  byte_length = 2
}


locals {
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

  tags = merge(
    var.tags,
    {
      RootTFModule = replace(basename(path.cwd), "_", "-") # tag names based on the directory name
      GithubRepo   = "github.com/defenseunicorns/narwhal-delivery-iac-swf-reference-deployment"
    }
  )
  s3_bucket_polcy_name = join("-", compact([local.prefix, var.policy_name, "s3-access-policy", local.suffix]))
}

## This will create a policy for the S3 Buckets
resource "aws_iam_policy" "s3_bucket_policy" {
  name        = local.s3_bucket_polcy_name
  path        = "/"
  description = "IRSA policy to access buckets."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::uds-${bucket_name}-${local.suffix}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          for bucket_name in var.bucket_names :
          "arn:${data.aws_partition.current.partition}:s3:::uds-${bucket_name}-${local.suffix}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = [var.kms_key_arn]
      }
    ]
  })
  tags = local.tags
}

module "irsa_role" {
  for_each = toset(var.serviceaccount_names)

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=v5.34.0"

  role_name = join("-", compact([local.prefix, each.value, "s3-role", local.suffix]))

  role_policy_arns = {
    policy = aws_iam_policy.s3_bucket_policy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.k8s_namespace}:${each.value}"]
    }
  }
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  for_each = toset(var.serviceaccount_names)

  role       = join("-", compact([local.prefix, each.value, "s3-role", local.suffix]))
  policy_arn = aws_iam_policy.s3_bucket_policy.arn

  depends_on = [module.irsa_role]
}
