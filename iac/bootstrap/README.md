https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.34 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tfstate_backend"></a> [tfstate\_backend](#module\_tfstate\_backend) | cloudposse/tfstate-backend/aws | 1.4.0 |
| <a name="module_zarf_s3_bucket"></a> [zarf\_s3\_bucket](#module\_zarf\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arn_format"></a> [arn\_format](#input\_arn\_format) | ARN format to be used. May be changed to support deployment in GovCloud regions. | `string` | `"arn:aws-us-gov"` | no |
| <a name="input_bucket_enabled"></a> [bucket\_enabled](#input\_bucket\_enabled) | Whether to create the s3 bucket. | `bool` | `true` | no |
| <a name="input_bucket_ownership_enforced_enabled"></a> [bucket\_ownership\_enforced\_enabled](#input\_bucket\_ownership\_enforced\_enabled) | Whether S3 bucket ownership is enforced | `bool` | `true` | no |
| <a name="input_create_local_backend_file"></a> [create\_local\_backend\_file](#input\_create\_local\_backend\_file) | only accepts true or false, if true it will create a backend.tf file in the current directory. | `bool` | `true` | no |
| <a name="input_dynamodb_enabled"></a> [dynamodb\_enabled](#input\_dynamodb\_enabled) | Whether to create the dynamodb table. | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, e.g. 'app' or 'jenkins' | `string` | `"narwhal-delivery-iac-swf"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-gov-west-1"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_terraform_state_file"></a> [terraform\_state\_file](#input\_terraform\_state\_file) | The path to the state file inside the bucket | `string` | `"terraform.tfstate"` | no |
| <a name="input_zarf_bucket_lifecycle_rules"></a> [zarf\_bucket\_lifecycle\_rules](#input\_zarf\_bucket\_lifecycle\_rules) | List of maps of S3 bucket lifecycle rules | `list(map(string))` | `[]` | no |
| <a name="input_zarf_bucket_mfa_delete"></a> [zarf\_bucket\_mfa\_delete](#input\_zarf\_bucket\_mfa\_delete) | Enable MFA delete for the S3 bucket | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_terraform_backend_config"></a> [terraform\_backend\_config](#output\_terraform\_backend\_config) | rendered terraform backend config |
| <a name="output_tfstate_backend_dynamodb_table_id"></a> [tfstate\_backend\_dynamodb\_table\_id](#output\_tfstate\_backend\_dynamodb\_table\_id) | tf state backend DynamoDB table ID |
| <a name="output_tfstate_backend_dynamodb_table_name"></a> [tfstate\_backend\_dynamodb\_table\_name](#output\_tfstate\_backend\_dynamodb\_table\_name) | tfstate backend DynamoDB table name |
| <a name="output_tfstate_backend_s3_bucket_id"></a> [tfstate\_backend\_s3\_bucket\_id](#output\_tfstate\_backend\_s3\_bucket\_id) | tfstate backend S3 bucket ID |
| <a name="output_zarf_bucket_id"></a> [zarf\_bucket\_id](#output\_zarf\_bucket\_id) | Zarf S3 bucket ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
