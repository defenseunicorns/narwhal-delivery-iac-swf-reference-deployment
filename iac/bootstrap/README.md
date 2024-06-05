# bootstrap

This module is used to bootstrap s3 and dynamodb for state backend, template partial backend and tfvar files in this repository for each environment under iac/env.

This module templates out a `backend.tf` file and a `${root-module}-backend.tfconfig` file that are used to configure terraform to utilize an s3 backend. Each environment (dev, staging, prod, etc) will have its own backend-config file that is utilize different backend settings. This pattern is known as [terraform partial backend configuration](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#partial-configuration).

Steps to use this module:

1. Initialize the bootstrap module in the environment you want to use it in
2. Apply the bootstrap module using relevant tfvars files
3. Re-init backend to use the newly created backend

> [!WARNING]
When bootstrapping multiple environments and the same root module, you'll need to remove your local `.terraform` directory and `backend.tf` file before re-initializing the backend since it will need to create the s3 bucket and dynamodb table for each environment as well as the `${root-module}-backend.tfconfig` files. Once this has been completed, the same `backend.tf` can be used across all environments as long as the contents of the `backend.tf` file are the same.

## Usage

example uds runner usage:

``` bash
# from the root of the repo

export ENV=dev
#initial runs
uds run one-time-bootstrap-env --set ENV=$ENV

#subsequent runs for $ENV
uds run apply-bootstrap --set ENV=$ENV

# re-init to use a different ENV and also s3 backend
export ENV=stg
uds run remove-backend-configuration-files
uds run one-time-bootstrap-env --set ENV=$ENV
uds run apply-bootstrap --set ENV=$ENV
```

example terraform usage:

> [!IMPORTANT]
> This scenario assumes first time bootstrapping for ENV.

``` bash
# from the root of this module

env=dev
root_module=bootstrap

pushd "iac/${root_module}"
terraform init

# var-file path relative to current working directory
terraform apply -var-file ../env/${env}/tfvars/common.terraform.tfvars -var-file ../env/${env}/tfvars/${root_module}.terraform.tfvars -auto-approve

# init again to use the new s3 backend
# you can just run 'terraform init' on subsequent runs if you are not changing the backend or ENV context
terraform init --reconfigure --backend-config=../env/${env}/backends/${root_module}-backend.tfconfig
```

<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
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
| <a name="module_tfstate_backend"></a> [tfstate\_backend](#module\_tfstate\_backend) | git::<https://github.com/cloudposse/terraform-aws-tfstate-backend.git> | tags/1.4.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.backend_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.backend_tf_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.context_tfvars_template](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_dynamodb_table_name"></a> [backend\_dynamodb\_table\_name](#input\_backend\_dynamodb\_table\_name) | The name of the DynamoDB table | `string` | `""` | no |
| <a name="input_backend_s3_bucket_name"></a> [backend\_s3\_bucket\_name](#input\_backend\_s3\_bucket\_name) | The name of the S3 bucket | `string` | `""` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | List of root module backends to template | `list(string)` | <pre>[<br>  "bootstrap",<br>  "swf"<br>]</pre> | no |
| <a name="input_bucket_ownership_enforced_enabled"></a> [bucket\_ownership\_enforced\_enabled](#input\_bucket\_ownership\_enforced\_enabled) | Whether S3 bucket ownership is enforced | `bool` | `true` | no |
| <a name="input_create_context_tfvars"></a> [create\_context\_tfvars](#input\_create\_context\_tfvars) | A boolean that indicates whether to create the context.tfvars file | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, e.g. 'app' or 'jenkins' | `string` | `"narwhal-delivery-iac-swf"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | name prefix to prepend to most resources, if not defined, created as: 'namespace-stage-name' | `string` | `""` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | for the s3 backend config file | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | region to deploy resources, this is set via ../env/$env/common.terraform.tfvars | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | name suffix to append to most resources, if not defined, randomly generated | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_terraform_backend_config_template_file"></a> [terraform\_backend\_config\_template\_file](#input\_terraform\_backend\_config\_template\_file) | The path to the backend config template file, this a backend Partial Configuration that is scalable across multiple environments | `string` | `"../templates/backend.tfconfig.tpl"` | no |
| <a name="input_terraform_backend_tf_template_file"></a> [terraform\_backend\_tf\_template\_file](#input\_terraform\_backend\_tf\_template\_file) | The path to the backend tf template file, this a backend Partial Configuration that is scalable across multiple environments | `string` | `"../templates/backend.tf.tpl"` | no |
| <a name="input_terraform_context_tfvars_template_file"></a> [terraform\_context\_tfvars\_template\_file](#input\_terraform\_context\_tfvars\_template\_file) | The path to the context tfvars template file, this a backend Partial Configuration that is scalable across multiple environments | `string` | `"../templates/context.tf.tpl"` | no |
| <a name="input_terraform_state_file"></a> [terraform\_state\_file](#input\_terraform\_state\_file) | The path to the state file inside the bucket | `string` | `"terraform.tfstate"` | no |
| <a name="input_tfstate_backend_name"></a> [tfstate\_backend\_name](#input\_tfstate\_backend\_name) | The naming convention for the tfstate backend | `string` | `"tfstate"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_tfstate_backend_dynamodb_table_id"></a> [account\_tfstate\_backend\_dynamodb\_table\_id](#output\_account\_tfstate\_backend\_dynamodb\_table\_id) | tf state backend DynamoDB table ID |
| <a name="output_account_tfstate_backend_dynamodb_table_name"></a> [account\_tfstate\_backend\_dynamodb\_table\_name](#output\_account\_tfstate\_backend\_dynamodb\_table\_name) | tfstate backend DynamoDB table name |
| <a name="output_account_tfstate_backend_s3_bucket_id"></a> [account\_tfstate\_backend\_s3\_bucket\_id](#output\_account\_tfstate\_backend\_s3\_bucket\_id) | tfstate backend S3 bucket ID |
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
