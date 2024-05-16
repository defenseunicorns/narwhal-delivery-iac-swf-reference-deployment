# variable "namespace" {
#   type        = string
#   default     = "du"
#   description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
# }

variable "stage" {
  type        = string
  default     = "test"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

# variable "name" {
#   type        = string
#   description = "Name, e.g. 'app' or 'jenkins'"
#   default     = "zarf-registry"
# }

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

variable "oidc_provider_arn" {
  description = "The URL of the OIDC identity provider for the EKS cluster."
  type        = string
  default     = ""
}

#####

variable "policy_name" {
  description = "Name of the policy"
  type        = string
  default     = "default"
}

variable "k8s_namespace" {
  description = "Namespace for the IAM S3 Bucket Role"
  type        = string
}

variable "irsa_iam_policy" {
  description = "Override for default irsa policy. This value needs to be a json encoded string."
  type        = string
  default     = ""
}

variable "bucket_names" {
  description = "List of buckets"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS Key ARN"
  type        = string
}

variable "serviceaccount_names" {
  description = "List of service accounts"
  type        = list(string)
  default     = []
}

variable "role_permissions_boundary" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}
