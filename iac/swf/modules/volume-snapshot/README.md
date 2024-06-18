# volume-snapshot

<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dlm_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |
| [aws_iam_role.dlm_lifecycle_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.dlm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dlm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dlm_role_name"></a> [dlm\_role\_name](#input\_dlm\_role\_name) | Name for the DLM IAM role policy | `string` | `""` | no |
| <a name="input_lifecycle_policy_description"></a> [lifecycle\_policy\_description](#input\_lifecycle\_policy\_description) | Description of the lifecycle policy | `string` | `""` | no |
| <a name="input_schedule_details"></a> [schedule\_details](#input\_schedule\_details) | Details of the schedule - Cron reference https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cron-expressions.html | <pre>list(object({<br>    name = string<br>    create_rule = object({<br>      cron_expression = string<br>    })<br>    retain_rule = object({<br>      count = number<br>    })<br>  }))</pre> | <pre>[<br>  {<br>    "create_rule": {<br>      "cron_expression": "cron(0 0 * * *)"<br>    },<br>    "name": "Daily",<br>    "retain_rule": {<br>      "count": 7<br>    }<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to lifecycle policy resources | `map(string)` | `{}` | no |
| <a name="input_target_tags"></a> [target\_tags](#input\_target\_tags) | List of tags to target snapshots by, is OR operation | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dlm_target_tags"></a> [dlm\_target\_tags](#output\_dlm\_target\_tags) | Tags to reference when selecting volumes to snapshot |
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
