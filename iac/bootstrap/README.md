https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.34 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.34 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 1.3 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tfstate_backend"></a> [tfstate\_backend](#module\_tfstate\_backend) | git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git | tags/1.4.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.backend_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_dynamodb_table_name"></a> [backend\_dynamodb\_table\_name](#input\_backend\_dynamodb\_table\_name) | The name of the DynamoDB table | `string` | `""` | no |
| <a name="input_backend_s3_bucket_name"></a> [backend\_s3\_bucket\_name](#input\_backend\_s3\_bucket\_name) | The name of the S3 bucket | `string` | `""` | no |
| <a name="input_bucket_ownership_enforced_enabled"></a> [bucket\_ownership\_enforced\_enabled](#input\_bucket\_ownership\_enforced\_enabled) | Whether S3 bucket ownership is enforced | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, e.g. 'app' or 'jenkins' | `string` | `"narwhal-delivery-iac-swf"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | name prefix to prepend to most resources, if not defined, created as: 'namespace-stage-name' | `string` | `""` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | for the s3 backend config file | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | region to deploy resources, this is set via ../env/$env/common.terraform.tfvars | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | name suffix to append to most resources, if not defined, randomly generated | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_terraform_backend_config_template_file"></a> [terraform\_backend\_config\_template\_file](#input\_terraform\_backend\_config\_template\_file) | The path to the backend config template file | `string` | `"../templates/backend.tf.tpl"` | no |
| <a name="input_terraform_state_file"></a> [terraform\_state\_file](#input\_terraform\_state\_file) | The path to the state file inside the bucket | `string` | `"terraform.tfstate"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_tfstate_backend_dynamodb_table_id"></a> [account\_tfstate\_backend\_dynamodb\_table\_id](#output\_account\_tfstate\_backend\_dynamodb\_table\_id) | tf state backend DynamoDB table ID |
| <a name="output_account_tfstate_backend_dynamodb_table_name"></a> [account\_tfstate\_backend\_dynamodb\_table\_name](#output\_account\_tfstate\_backend\_dynamodb\_table\_name) | tfstate backend DynamoDB table name |
| <a name="output_account_tfstate_backend_s3_bucket_id"></a> [account\_tfstate\_backend\_s3\_bucket\_id](#output\_account\_tfstate\_backend\_s3\_bucket\_id) | tfstate backend S3 bucket ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
