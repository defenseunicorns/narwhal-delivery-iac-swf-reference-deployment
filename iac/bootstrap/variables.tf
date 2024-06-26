variable "region" {
  type        = string
  description = "region to deploy resources, this is set via ../env/$env/common.terraform.tfvars"
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

variable "backends" {
  type        = list(string)
  description = "List of root module backends to template"
  default     = ["bootstrap", "swf"]
}

variable "tfstate_backend_name" {
  type        = string
  description = "The naming convention for the tfstate backend"
  default     = "tfstate"
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

variable "profile" {
  type        = string
  description = "for the s3 backend config file"
  default     = ""
}

# variable "terraform_templates_files_path_prefix" {
#   type        = string
#   description = "This is a path prefix variable to the templates directory"
#   default     = "../templates"
# }

variable "terraform_context_tfvars_template_file" {
  type        = string
  description = "The path to the context tfvars template file, this a backend Partial Configuration that is scalable across multiple environments"
  default     = "../templates/context.tf.tpl"
}

variable "create_context_tfvars" {
  type        = bool
  description = "A boolean that indicates whether to create the context.tfvars file"
  default     = true

}

variable "terraform_backend_config_template_file" {
  type        = string
  description = "The path to the backend config template file, this a backend Partial Configuration that is scalable across multiple environments"
  default     = "../templates/backend.tfconfig.tpl"
}

variable "terraform_backend_tf_template_file" {
  type        = string
  description = "The path to the backend tf template file, this a backend Partial Configuration that is scalable across multiple environments"
  default     = "../templates/backend.tf.tpl"
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
