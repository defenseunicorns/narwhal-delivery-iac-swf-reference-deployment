variable "schedule_details" {
  description = "Details of the schedule - Cron reference https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cron-expressions.html"
  type = list(object({
    name = string
    create_rule = object({
      cron_expression = string
    })
    retain_rule = object({
      count = number
    })
  }))
  default = [{
    name = "Daily"
    create_rule = {
      cron_expression = "cron(0 0 * * *)"
    }
    retain_rule = {
      count = 7
    }
  }]
}

variable "target_tags" {
  description = "List of tags to target snapshots by, is OR operation"
  type        = map(string)
}

variable "lifecycle_policy_description" {
  description = "Description of the lifecycle policy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to lifecycle policy resources"
  type        = map(string)
  default     = {}
}

variable "dlm_role_name" {
  description = "Name for the DLM IAM role policy"
  type        = string
  default     = ""
}
