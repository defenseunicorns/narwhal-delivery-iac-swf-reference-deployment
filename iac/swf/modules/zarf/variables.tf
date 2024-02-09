variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "name_prefix" {
  description = "The prefix to use when naming all resources"
  type        = string
  default     = "iac-swf"
  validation {
    condition     = length(local.name_prefix) <= 20
    error_message = "The name prefix cannot be more than 20 characters"
  }
}

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
  default     = "narwhal-delivery-iac-swf"
}

variable "s3_bucket_versioning_enabled" {
  type        = bool
  description = "Enable versioning for the S3 bucket"
  default     = true
}
variable "bucket_mfa_delete" {
  type        = bool
  description = "Enable MFA delete for the S3 bucket"
  default     = false
}

variable "bucket_lifecycle_rule" {
  type        = list(map(string))
  description = "List of maps of S3 bucket lifecycle rules"
  default     = []
}
