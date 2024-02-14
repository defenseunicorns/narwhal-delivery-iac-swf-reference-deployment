# Create Cloud resources for zarf specifically

1. creates s3 bucket for docker registry
2. creates IRSA role for s3 access
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git | v4.1.0 |
| <a name="module_zarf_irsa_policy"></a> [zarf\_irsa\_policy](#module\_zarf\_irsa\_policy) | git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy | v5.34.0 |
| <a name="module_zarf_irsa_role"></a> [zarf\_irsa\_role](#module\_zarf\_irsa\_role) | git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks | v5.34.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_bucket_policy"></a> [attach\_bucket\_policy](#input\_attach\_bucket\_policy) | Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | `bool` | `false` | no |
| <a name="input_attach_public_bucket_policy"></a> [attach\_public\_bucket\_policy](#input\_attach\_public\_bucket\_policy) | Controls if S3 bucket should have public bucket policy attached (set to `true` to use value of `public_policy` as bucket policy) | `bool` | `true` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | (Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to true. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | (Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to true. | `bool` | `true` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_create_irsa_role"></a> [create\_irsa\_role](#input\_create\_irsa\_role) | Determines whether to create an IAM role for IRSA. | `bool` | `true` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Determines whether to create an S3 bucket for storing CloudTrail logs. If not, an existing bucket name must be provided. | `bool` | `true` | no |
| <a name="input_enable_s3_bucket_server_side_encryption_configuration"></a> [enable\_s3\_bucket\_server\_side\_encryption\_configuration](#input\_enable\_s3\_bucket\_server\_side\_encryption\_configuration) | Whether to enable server-side encryption configuration. | `bool` | `true` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | (Optional) Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to true. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, e.g. 'app' or 'jenkins' | `string` | `"zarf-registry"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The URL of the OIDC identity provider for the EKS cluster. | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | name prefix to prepend to most resources, if not defined, created as: 'namespace-stage-name' | `string` | `""` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to true. | `bool` | `true` | no |
| <a name="input_s3_bucket_force_destroy"></a> [s3\_bucket\_force\_destroy](#input\_s3\_bucket\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_s3_bucket_lifecycle_rules"></a> [s3\_bucket\_lifecycle\_rules](#input\_s3\_bucket\_lifecycle\_rules) | List of maps containing configuration of object lifecycle management. | `any` | <pre>[<br>  {<br>    "abort_incomplete_multipart_upload_days": 7,<br>    "expiration": {<br>      "days": 365<br>    },<br>    "id": "whatever",<br>    "status": "Enabled",<br>    "transition": [<br>      {<br>        "days": 30,<br>        "storage_class": "STANDARD_IA"<br>      },<br>      {<br>        "days": 60,<br>        "storage_class": "GLACIER"<br>      },<br>      {<br>        "days": 180,<br>        "storage_class": "DEEP_ARCHIVE"<br>      }<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the existing S3 bucket to be used if 'create\_s3\_bucket' is set to false. | `string` | `""` | no |
| <a name="input_s3_bucket_name_prefix"></a> [s3\_bucket\_name\_prefix](#input\_s3\_bucket\_name\_prefix) | The prefix to use for the S3 bucket name. | `string` | `""` | no |
| <a name="input_s3_bucket_name_use_prefix"></a> [s3\_bucket\_name\_use\_prefix](#input\_s3\_bucket\_name\_use\_prefix) | Determines whether to use the CloudTrail name as a prefix for the S3 bucket name. | `bool` | `true` | no |
| <a name="input_s3_bucket_server_side_encryption_configuration"></a> [s3\_bucket\_server\_side\_encryption\_configuration](#input\_s3\_bucket\_server\_side\_encryption\_configuration) | Map containing server-side encryption configuration. | `any` | `{}` | no |
| <a name="input_s3_bucket_versioning"></a> [s3\_bucket\_versioning](#input\_s3\_bucket\_versioning) | Map containing versioning configuration. | `map(string)` | <pre>{<br>  "enabled": false,<br>  "mfa_delete": false<br>}</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | name suffix to append to most resources, if not defined, randomly generated | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_zarf_irsa_policy_name"></a> [zarf\_irsa\_policy\_name](#input\_zarf\_irsa\_policy\_name) | The name of the IAM policy to create for IRSA. | `string` | `""` | no |
| <a name="input_zarf_irsa_role_name"></a> [zarf\_irsa\_role\_name](#input\_zarf\_irsa\_role\_name) | The name of the IAM role to create for IRSA. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_k8s_sa_name"></a> [irsa\_k8s\_sa\_name](#output\_irsa\_k8s\_sa\_name) | zarf IRSA k8s service account name in k8s |
| <a name="output_irsa_role_arn"></a> [irsa\_role\_arn](#output\_irsa\_role\_arn) | zarf IRSA role ARN |
| <a name="output_zarf_registry_s3_bucket_name"></a> [zarf\_registry\_s3\_bucket\_name](#output\_zarf\_registry\_s3\_bucket\_name) | zarf registry S3 bucket name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
