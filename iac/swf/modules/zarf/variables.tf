variable "namespace" {
  type        = string
  default     = "du"
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  default     = "test"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  description = "Name, e.g. 'app' or 'jenkins'"
  default     = "zarf-registry"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  type        = string
  description = "name prefix to prepend to most resources, if not defined, created as: 'namespace-stage-name'"
  default     = ""
}

variable "suffix" {
  type        = string
  description = "name suffix to append to most resources, if not defined, randomly generated"
  default     = ""
}

################################################################################
# S3 Bucket
################################################################################
#region
variable "create_s3_bucket" {
  description = "Determines whether to create an S3 bucket for storing CloudTrail logs. If not, an existing bucket name must be provided."
  type        = bool
  default     = true
}

variable "s3_bucket_name_use_prefix" {
  description = "Determines whether to use the CloudTrail name as a prefix for the S3 bucket name."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "The name of the existing S3 bucket to be used if 'create_s3_bucket' is set to false."
  type        = string
  default     = ""
}

variable "s3_bucket_name_prefix" {
  description = "The prefix to use for the S3 bucket name."
  type        = string
  default     = ""
}

variable "s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "attach_bucket_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "attach_public_bucket_policy" {
  description = "Controls if S3 bucket should have public bucket policy attached (set to `true` to use value of `public_policy` as bucket policy)"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "(Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to true."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "(Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to true."
  type        = bool
  default     = true

}

variable "ignore_public_acls" {
  description = "(Optional) Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to true."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "(Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to true."
  type        = bool
  default     = true
}

variable "s3_bucket_versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default = {
    enabled    = false
    mfa_delete = false
  }
}

variable "s3_bucket_server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default     = {}
}

variable "enable_s3_bucket_server_side_encryption_configuration" {
  description = "Whether to enable server-side encryption configuration."
  type        = bool
  default     = true
}

variable "s3_bucket_lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default = [
    {
      id                                     = "whatever"
      status                                 = "Enabled"
      abort_incomplete_multipart_upload_days = 7

      #see https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html#sc-compare
      # https://docs.aws.amazon.com/AmazonS3/latest/API/API_Transition.html
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        },
        {
          days          = 180
          storage_class = "DEEP_ARCHIVE"
        },
      ]

      expiration = {
        days = 365
      }
    }
  ]
}

################################################################################
# IRSA
################################################################################
variable "create_irsa_role" {
  description = "Determines whether to create an IAM role for IRSA."
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  description = "The URL of the OIDC identity provider for the EKS cluster."
  type        = string
  default     = ""
}

variable "zarf_irsa_role_name" {
  description = "The name of the IAM role to create for IRSA."
  type        = string
  default     = ""
}

variable "zarf_irsa_policy_name" {
  description = "The name of the IAM policy to create for IRSA."
  type        = string
  default     = ""
}
