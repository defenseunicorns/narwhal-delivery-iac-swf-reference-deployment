# terraform

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.4.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.62.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.62.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | git::https://github.com/defenseunicorns/terraform-aws-bastion.git | v0.0.11 |
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | ~> 2.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | git::https://github.com/defenseunicorns/terraform-aws-eks.git | v0.0.14 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | ~> 2.0 |
| <a name="module_password_lambda"></a> [password\_lambda](#module\_password\_lambda) | git::https://github.com/defenseunicorns/terraform-aws-lambda.git//modules/password-rotation | v0.0.3 |
| <a name="module_ssm_kms_key"></a> [ssm\_kms\_key](#module\_ssm\_kms\_key) | terraform-aws-modules/kms/aws | ~> 2.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/defenseunicorns/terraform-aws-vpc.git | v0.1.5 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.access_log_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_public_access_block.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sqs_queue.access_log_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ami.amazonlinux2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.eks_default_bottlerocket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_access_log_expire_days"></a> [access\_log\_expire\_days](#input\_access\_log\_expire\_days) | Number of days to wait before deleting access logs | `number` | `30` | no |
| <a name="input_arn_format"></a> [arn\_format](#input\_arn\_format) | ARN format to be used. May be changed to support deployment in GovCloud regions. | `string` | `"arn:aws-us-gov"` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP` | `string` | `"API"` | no |
| <a name="input_aws_admin_usernames"></a> [aws\_admin\_usernames](#input\_aws\_admin\_usernames) | A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user running the terraform as an admin | `list(string)` | `[]` | no |
| <a name="input_aws_efs_csi_driver"></a> [aws\_efs\_csi\_driver](#input\_aws\_efs\_csi\_driver) | AWS EFS CSI Driver helm chart config | `any` | `{}` | no |
| <a name="input_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#input\_aws\_load\_balancer\_controller) | AWS Loadbalancer Controller Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#input\_aws\_node\_termination\_handler) | AWS Node Termination Handler config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | value for the instance type of the EKS worker nodes | `string` | `"m5.xlarge"` | no |
| <a name="input_bastion_ssh_password"></a> [bastion\_ssh\_password](#input\_bastion\_ssh\_password) | The SSH password to use for the bastion if SSM authentication is used | `string` | `"my-password"` | no |
| <a name="input_bastion_ssh_user"></a> [bastion\_ssh\_user](#input\_bastion\_ssh\_user) | The SSH user to use for the bastion | `string` | `"ec2-user"` | no |
| <a name="input_bastion_tenancy"></a> [bastion\_tenancy](#input\_bastion\_tenancy) | The tenancy of the bastion | `string` | `"dedicated"` | no |
| <a name="input_bucket_enabled"></a> [bucket\_enabled](#input\_bucket\_enabled) | Whether to create the s3 bucket. | `bool` | `true` | no |
| <a name="input_bucket_ownership_enforced_enabled"></a> [bucket\_ownership\_enforced\_enabled](#input\_bucket\_ownership\_enforced\_enabled) | Whether S3 bucket ownership is enforced | `bool` | `true` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Nested of eks native add-ons and their associated parameters.<br>See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_add-on for supported values.<br>See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf#L44-L60 for upstream example.<br><br>to see available eks marketplace addons available for your cluster's version run:<br>aws eks describe-addon-versions --kubernetes-version $k8s\_cluster\_version --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table | `any` | `{}` | no |
| <a name="input_cluster_autoscaler"></a> [cluster\_autoscaler](#input\_cluster\_autoscaler) | Cluster Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Whether to enable public access to the EKS cluster | `bool` | `false` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for EKS cluster | `string` | `"1.27"` | no |
| <a name="input_create_kubernetes_resources"></a> [create\_kubernetes\_resources](#input\_create\_kubernetes\_resources) | If true, kubernetes resources related to non-marketplace addons to will be created | `bool` | `false` | no |
| <a name="input_create_local_backend_file"></a> [create\_local\_backend\_file](#input\_create\_local\_backend\_file) | only accepts true or false, if true it will create a backend.tf file in the current directory. | `bool` | `true` | no |
| <a name="input_create_ssm_parameters"></a> [create\_ssm\_parameters](#input\_create\_ssm\_parameters) | Create SSM parameters for values from eks blueprints addons | `bool` | `true` | no |
| <a name="input_cron_schedule_password_rotation"></a> [cron\_schedule\_password\_rotation](#input\_cron\_schedule\_password\_rotation) | Schedule for password change function to run on | `string` | `"cron(0 0 1 * ? *)"` | no |
| <a name="input_dataplane_wait_duration"></a> [dataplane\_wait\_duration](#input\_dataplane\_wait\_duration) | The duration to wait for the EKS cluster to be ready before creating the node groups | `string` | `"30s"` | no |
| <a name="input_dynamodb_enabled"></a> [dynamodb\_enabled](#input\_dynamodb\_enabled) | Whether to create the dynamodb table. | `bool` | `true` | no |
| <a name="input_eks_use_mfa"></a> [eks\_use\_mfa](#input\_eks\_use\_mfa) | Use MFA for auth\_eks\_role | `bool` | n/a | yes |
| <a name="input_eks_worker_tenancy"></a> [eks\_worker\_tenancy](#input\_eks\_worker\_tenancy) | The tenancy of the EKS worker nodes | `string` | `"dedicated"` | no |
| <a name="input_enable_amazon_eks_aws_ebs_csi_driver"></a> [enable\_amazon\_eks\_aws\_ebs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_ebs\_csi\_driver) | Enable EKS Managed AWS EBS CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_aws_efs_csi_driver"></a> [enable\_amazon\_eks\_aws\_efs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_efs\_csi\_driver) | Enable EFS CSI add-on | `bool` | `false` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Loadbalancer Controller add-on | `bool` | `false` | no |
| <a name="input_enable_aws_node_termination_handler"></a> [enable\_aws\_node\_termination\_handler](#input\_enable\_aws\_node\_termination\_handler) | Enable AWS Node Termination Handler add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Enable Cluster autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `true` | no |
| <a name="input_enable_gp3_default_storage_class"></a> [enable\_gp3\_default\_storage\_class](#input\_enable\_gp3\_default\_storage\_class) | Enable gp3 as default storage class | `bool` | `false` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Enable metrics server add-on | `bool` | `false` | no |
| <a name="input_enable_secrets_store_csi_driver"></a> [enable\_secrets\_store\_csi\_driver](#input\_enable\_secrets\_store\_csi\_driver) | Enable k8s Secret Store CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_sqs_events_on_access_log_access"></a> [enable\_sqs\_events\_on\_access\_log\_access](#input\_enable\_sqs\_events\_on\_access\_log\_access) | If true, generates an SQS event whenever on object is created in the Access Log bucket, which happens whenever a server access log is generated by any entity. This will potentially generate a lot of events, so use with caution. | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates the S3 bucket can be destroyed even if it contains objects. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for IAM roles | `string` | `null` | no |
| <a name="input_keycloak_enabled"></a> [keycloak\_enabled](#input\_keycloak\_enabled) | Enable Keycloak dedicated nodegroup | `bool` | `false` | no |
| <a name="input_kms_key_deletion_window"></a> [kms\_key\_deletion\_window](#input\_kms\_key\_deletion\_window) | Waiting period for scheduled KMS Key deletion. Can be 7-30 days. | `number` | `7` | no |
| <a name="input_metrics_server"></a> [metrics\_server](#input\_metrics\_server) | Metrics Server config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, e.g. 'app' or 'jenkins' | `string` | `"narwhal-delivery-iac-swf"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix to use when naming all resources | `string` | `"iac-swf"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_num_azs"></a> [num\_azs](#input\_num\_azs) | The number of AZs to use | `number` | `3` | no |
| <a name="input_reclaim_policy"></a> [reclaim\_policy](#input\_reclaim\_policy) | Reclaim policy for EFS storage class, valid options are Delete and Retain | `string` | `"Delete"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name. If not provided, the name will be generated by the label module in the format namespace-stage-name | `string` | `""` | no |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | A list of secondary CIDR blocks for the VPC | `list(string)` | `[]` | no |
| <a name="input_secrets_store_csi_driver"></a> [secrets\_store\_csi\_driver](#input\_secrets\_store\_csi\_driver) | k8s Secret Store CSI Driver Helm Chart config | `any` | `{}` | no |
| <a name="input_slack_notification_enabled"></a> [slack\_notification\_enabled](#input\_slack\_notification\_enabled) | enable slack notifications for password rotation function. If enabled a slack webhook url will also need to be provided for this to work | `bool` | `false` | no |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | value | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_storageclass_reclaim_policy"></a> [storageclass\_reclaim\_policy](#input\_storageclass\_reclaim\_policy) | Reclaim policy for gp3 storage class, valid options are Delete and Retain | `string` | `"Delete"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | This needs to be a list of users that will be on your ec2 instances that need password changes. | `list(string)` | `[]` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_zarf_version"></a> [zarf\_version](#input\_zarf\_version) | The version of Zarf to use | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | The ID of the bastion host |
| <a name="output_bastion_private_dns"></a> [bastion\_private\_dns](#output\_bastion\_private\_dns) | The private DNS address of the bastion host |
| <a name="output_bastion_region"></a> [bastion\_region](#output\_bastion\_region) | The region that the bastion host was deployed to |
| <a name="output_efs_storageclass_name"></a> [efs\_storageclass\_name](#output\_efs\_storageclass\_name) | The name of the EFS storageclass that was created (if var.enable\_amazon\_eks\_aws\_efs\_csi\_driver was set to true) |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
| <a name="output_lambda_password_function_arn"></a> [lambda\_password\_function\_arn](#output\_lambda\_password\_function\_arn) | Arn for lambda password function |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | The CIDR block of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
