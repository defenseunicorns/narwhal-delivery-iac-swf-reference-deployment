# transit-gateway

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.30.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_transit_gateway"></a> [transit\_gateway](#module\_transit\_gateway) | git::https://github.com/defenseunicorns/terraform-aws-transit-gateway.git | v0.0.1 |
| <a name="module_transit_gateway_attachment"></a> [transit\_gateway\_attachment](#module\_transit\_gateway\_attachment) | git::https://github.com/defenseunicorns/terraform-aws-transit-gateway.git | v0.0.2 |

## Resources

| Name | Type |
|------|------|
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [terraform_remote_state.swf_state](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the S3 bucket where the Terraform state file is stored | `string` | n/a | yes |
| <a name="input_key"></a> [key](#input\_key) | The name of the Terraform state file to retrieve state information from | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Transit Gateway | `string` | `"tgw"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | name prefix to prepend to most resources, if not defined, created as: 'namespace-stage-name' | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | name suffix to append to most resources, if not defined, randomly generated | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_config_map"></a> [route\_config\_map](#output\_route\_config\_map) | n/a |
| <a name="output_transit_gateway_attachment"></a> [transit\_gateway\_attachment](#output\_transit\_gateway\_attachment) | n/a |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
