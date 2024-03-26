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

variable "source_bucket_name" {
  description = "Name of the source bucket"
  type        = string
}

variable "source_bucket_arn" {
  description = "ARN for the source bucket"
  type        = string
}

variable "destination_bucket_arn" {
  description = "ARN for the destination bucket"
  type        = string
}

variable "policy_name" {
  description = "Name of the policy"
  type        = string
  default     = "default"
}

variable "kms_key_arn" {
  description = "KMS Key ARN"
  type        = string
}
