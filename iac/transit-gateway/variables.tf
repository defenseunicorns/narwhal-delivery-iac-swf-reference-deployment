###########################################################
################## Global Settings ########################

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
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

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

###########################################################
################# Terraform State Backend #################
variable "bucket" {
  description = "The name of the S3 bucket where the Terraform state file is stored"
  type        = string
}

variable "key" {
  description = "The name of the Terraform state file to retrieve state information from"
  type        = string
}

###########################################################
################## Transit Gateway ########################

variable "tgw_name" {
  description = "The name of the Transit Gateway"
  type        = string
  default     = "tgw"
}

# variable "route_transit_gateway_attachment_id" {
#   description = "The ID of the route transit gateway attachment"
#   type        = string
# }

# variable "existing_transit_gateway_id" {
#   description = "The ID of the existing transit gateway"
#   type        = string
# }

# variable "existing_ingress_transit_gateway_route_table_name" {
#   description = "The name of the existing ingress transit gateway route table"
#   type        = string
# }
