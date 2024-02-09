variable "region" {
  type        = string
  description = "region to deploy resources, this is set via ../env/$env/common.terraform.tfvars"
}

variable "env" {
  type        = string
  description = "The environment name, this is set via ../env/$env/common.terraform.tfvars"
}

variable "arn_format" {
  type        = string
  default     = "arn:aws-us-gov" # module default = "arn:aws"
  description = "ARN format to be used. May be changed to support deployment in GovCloud regions."
}

variable "terraform_state_file" {
  type        = string
  default     = "terraform.tfstate"
  description = "The path to the state file inside the bucket"
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

variable "profile" {
  type        = string
  description = "for the s3 backend config file"
  default     = ""
}

variable "zarf_bucket_lifecycle_rules" {
  type        = list(map(string))
  description = "List of maps of S3 bucket lifecycle rules"
  default     = []
}

variable "zarf_bucket_mfa_delete" {
  type        = bool
  description = "Enable MFA delete for the S3 bucket"
  default     = false
}

variable "terraform_backend_config_template_file" {
  type        = string
  description = "The path to the backend config template file"
  default     = "../templates/backend.tf.tpl"
}

variable "swf_backend_config_file_name" {
  type        = string
  description = "The name of the backend config file"
  default     = "swf-backend.tf"
}

variable "backend_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default     = ""
}

variable "backend_dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
  default     = ""
}

variable "zarf_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default     = ""
}
