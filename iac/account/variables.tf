variable "region" {
  type    = string
  default = "us-gov-west-1"
}

variable "create_local_backend_file" {
  description = "only accepts true or false, if true it will create a backend.tf file in the current directory."
  type        = bool
  default     = true
}

variable "arn_format" {
  type        = string
  default     = "arn:aws-us-gov" # module default = "arn:aws"
  description = "ARN format to be used. May be changed to support deployment in GovCloud regions."
}

variable "bucket_enabled" {
  type        = bool
  default     = true
  description = "Whether to create the s3 bucket."
}

variable "dynamodb_enabled" {
  type        = bool
  default     = true
  description = "Whether to create the dynamodb table."
}

variable "bucket_ownership_enforced_enabled" {
  type        = bool
  default     = true
  description = "Whether S3 bucket ownership is enforced"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable"
  default     = false
}

# defaulted to empty string. tfstate_backend module will use 'namespace-stage-name' if not provided. Provide a value to override what is in main.tf
variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket name. If not provided, the name will be generated by the label module in the format namespace-stage-name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources."
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
