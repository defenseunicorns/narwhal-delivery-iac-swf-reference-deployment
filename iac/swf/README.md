# terraform

Steps to use this module:

1. init backend with the -reconfigure flag to use the newly created backend from the bootstrap process, see [Bootstrap README](../bootstrap/README.md)
2. Apply the terraform using relevant tfvars files. It should push the state file to the correct bucket and to the key defined in ../env/${env}/backends/swf-backend.tfconfig

example usage:

``` bash
# from the root of the repo

env=dev
root_module=swf

pushd "iac/${root_module}"
# init -reconfigure to use the new s3 backend
terraform init --reconfigure --force-copy --backend-config=../env/${env}/backends/${root_module}-backend.tfconfig

# apply terraform as you normally would
terraform apply -var-file ../env/${env}/tfvars/common.terraform.tfvars -var-file ../env/${env}/tfvars/${root_module}.terraform.tfvars
```

``` bash

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
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
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | git::https://github.com/defenseunicorns/terraform-aws-bastion.git | v0.0.11 |
| <a name="module_confluence_db"></a> [confluence\_db](#module\_confluence\_db) | terraform-aws-modules/rds/aws | 6.1.1 |
| <a name="module_confluence_kms_key"></a> [confluence\_kms\_key](#module\_confluence\_kms\_key) | github.com/defenseunicorns/terraform-aws-uds-kms | v0.0.2 |
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | ~> 2.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | git::https://github.com/defenseunicorns/terraform-aws-eks.git | v0.0.16 |
| <a name="module_gitlab_db"></a> [gitlab\_db](#module\_gitlab\_db) | terraform-aws-modules/rds/aws | 6.1.1 |
| <a name="module_gitlab_irsa_s3"></a> [gitlab\_irsa\_s3](#module\_gitlab\_irsa\_s3) | ./modules/irsa-s3 | n/a |
| <a name="module_gitlab_kms_key"></a> [gitlab\_kms\_key](#module\_gitlab\_kms\_key) | github.com/defenseunicorns/terraform-aws-uds-kms | v0.0.2 |
| <a name="module_gitlab_s3_bucket"></a> [gitlab\_s3\_bucket](#module\_gitlab\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 3.14.1 |
| <a name="module_jira_db"></a> [jira\_db](#module\_jira\_db) | terraform-aws-modules/rds/aws | 6.1.1 |
| <a name="module_jira_kms_key"></a> [jira\_kms\_key](#module\_jira\_kms\_key) | github.com/defenseunicorns/terraform-aws-uds-kms | v0.0.2 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | ~> 2.0 |
| <a name="module_password_lambda"></a> [password\_lambda](#module\_password\_lambda) | git::https://github.com/defenseunicorns/terraform-aws-lambda.git//modules/password-rotation | v0.0.3 |
| <a name="module_ssm_kms_key"></a> [ssm\_kms\_key](#module\_ssm\_kms\_key) | terraform-aws-modules/kms/aws | ~> 2.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/defenseunicorns/terraform-aws-vpc.git | v0.1.5 |
| <a name="module_zarf"></a> [zarf](#module\_zarf) | ./modules/zarf | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_replication_group.gitlab_redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.gitlab_redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.access_log_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_public_access_block.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.confluence_db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.gitlab_db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.gitlab_elasticache_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.jira_db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.uds_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.uds_config_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.confluence_rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.gitlab_rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.gitlab_redis_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.jira_rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sqs_queue.access_log_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_vpc_security_group_ingress_rule.confluence_rds_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.gitlab_rds_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.gitlab_redis_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.jira_rds_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [local_sensitive_file.uds_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.confluence_db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.gitlab_db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.gitlab_elasticache_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.jira_db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.amazonlinux2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.eks_default_bottlerocket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_access_log_expire_days"></a> [access\_log\_expire\_days](#input\_access\_log\_expire\_days) | Number of days to wait before deleting access logs | `number` | `30` | no |
| <a name="input_admin_role_name"></a> [admin\_role\_name](#input\_admin\_role\_name) | Name of the IAM role to create | `string` | `"unicorn-admin"` | no |
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of IAM users to add as administrators to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP` | `string` | `"API"` | no |
| <a name="input_aws_admin_usernames"></a> [aws\_admin\_usernames](#input\_aws\_admin\_usernames) | A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user running the terraform as an admin | `list(string)` | `[]` | no |
| <a name="input_aws_efs_csi_driver"></a> [aws\_efs\_csi\_driver](#input\_aws\_efs\_csi\_driver) | AWS EFS CSI Driver helm chart config | `any` | `{}` | no |
| <a name="input_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#input\_aws\_load\_balancer\_controller) | AWS Loadbalancer Controller Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#input\_aws\_node\_termination\_handler) | AWS Node Termination Handler config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | value for the instance type of the EKS worker nodes | `string` | `"m5.xlarge"` | no |
| <a name="input_bastion_ssh_password"></a> [bastion\_ssh\_password](#input\_bastion\_ssh\_password) | The SSH password to use for the bastion if SSM authentication is used | `string` | `"my-password"` | no |
| <a name="input_bastion_ssh_user"></a> [bastion\_ssh\_user](#input\_bastion\_ssh\_user) | The SSH user to use for the bastion | `string` | `"ec2-user"` | no |
| <a name="input_bastion_tenancy"></a> [bastion\_tenancy](#input\_bastion\_tenancy) | The tenancy of the bastion | `string` | `"dedicated"` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Nested of eks native add-ons and their associated parameters.<br>See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_add-on for supported values.<br>See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf#L44-L60 for upstream example.<br><br>to see available eks marketplace addons available for your cluster's version run:<br>aws eks describe-addon-versions --kubernetes-version $k8s\_cluster\_version --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table | `any` | `{}` | no |
| <a name="input_cluster_autoscaler"></a> [cluster\_autoscaler](#input\_cluster\_autoscaler) | Cluster Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Whether to enable public access to the EKS cluster | `bool` | `false` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for EKS cluster | `string` | `"1.27"` | no |
| <a name="input_confluence_db_idenitfier_prefix"></a> [confluence\_db\_idenitfier\_prefix](#input\_confluence\_db\_idenitfier\_prefix) | The prefix to use for the RDS instance identifier | `string` | `"confluence-db"` | no |
| <a name="input_confluence_db_name"></a> [confluence\_db\_name](#input\_confluence\_db\_name) | Name of the Confluence database. | `string` | `"confluencedb"` | no |
| <a name="input_confluence_kms_key_alias"></a> [confluence\_kms\_key\_alias](#input\_confluence\_kms\_key\_alias) | KMS Key Alias name prefix | `string` | `"confluence"` | no |
| <a name="input_confluence_rds_instance_class"></a> [confluence\_rds\_instance\_class](#input\_confluence\_rds\_instance\_class) | The instance class to use for the RDS instance | `string` | `"db.t4g.large"` | no |
| <a name="input_create_kubernetes_resources"></a> [create\_kubernetes\_resources](#input\_create\_kubernetes\_resources) | If true, kubernetes resources related to non-marketplace addons to will be created | `bool` | `false` | no |
| <a name="input_create_ssm_parameters"></a> [create\_ssm\_parameters](#input\_create\_ssm\_parameters) | Create SSM parameters for values from eks blueprints addons | `bool` | `true` | no |
| <a name="input_cron_schedule_password_rotation"></a> [cron\_schedule\_password\_rotation](#input\_cron\_schedule\_password\_rotation) | Schedule for password change function to run on | `string` | `"cron(0 0 1 * ? *)"` | no |
| <a name="input_dataplane_wait_duration"></a> [dataplane\_wait\_duration](#input\_dataplane\_wait\_duration) | The duration to wait for the EKS cluster to be ready before creating the node groups | `string` | `"30s"` | no |
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
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | If true, NAT Gateways will be created | `bool` | `false` | no |
| <a name="input_enable_public_subnets"></a> [enable\_public\_subnets](#input\_enable\_public\_subnets) | If true, public subnets will be created | `bool` | `false` | no |
| <a name="input_enable_secrets_store_csi_driver"></a> [enable\_secrets\_store\_csi\_driver](#input\_enable\_secrets\_store\_csi\_driver) | Enable k8s Secret Store CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_sqs_events_on_access_log_access"></a> [enable\_sqs\_events\_on\_access\_log\_access](#input\_enable\_sqs\_events\_on\_access\_log\_access) | If true, generates an SQS event whenever on object is created in the Access Log bucket, which happens whenever a server access log is generated by any entity. This will potentially generate a lot of events, so use with caution. | `bool` | `false` | no |
| <a name="input_gitlab_bucket_names"></a> [gitlab\_bucket\_names](#input\_gitlab\_bucket\_names) | List of buckets to create for GitLab | `list(string)` | <pre>[<br>  "gitlab-artifacts",<br>  "gitlab-backups",<br>  "gitlab-ci-secure-files",<br>  "gitlab-dependency-proxy",<br>  "gitlab-lfs",<br>  "gitlab-mr-diffs",<br>  "gitlab-packages",<br>  "gitlab-pages",<br>  "gitlab-terraform-state",<br>  "gitlab-uploads",<br>  "gitlab-registry",<br>  "gitlab-runner-cache",<br>  "gitlab-tmp"<br>]</pre> | no |
| <a name="input_gitlab_db_idenitfier_prefix"></a> [gitlab\_db\_idenitfier\_prefix](#input\_gitlab\_db\_idenitfier\_prefix) | The prefix to use for the RDS instance identifier | `string` | `"gitlab-db"` | no |
| <a name="input_gitlab_db_name"></a> [gitlab\_db\_name](#input\_gitlab\_db\_name) | Name of the GitLab database. | `string` | `"gitlabdb"` | no |
| <a name="input_gitlab_elasticache_cluster_name"></a> [gitlab\_elasticache\_cluster\_name](#input\_gitlab\_elasticache\_cluster\_name) | ElastiCache Cluster Name | `string` | `"gitlab"` | no |
| <a name="input_gitlab_kms_key_alias"></a> [gitlab\_kms\_key\_alias](#input\_gitlab\_kms\_key\_alias) | KMS Key Alias name prefix | `string` | `"gitlab"` | no |
| <a name="input_gitlab_namespace"></a> [gitlab\_namespace](#input\_gitlab\_namespace) | Namespace GitLab is deployed to | `string` | `"gitlab"` | no |
| <a name="input_gitlab_rds_instance_class"></a> [gitlab\_rds\_instance\_class](#input\_gitlab\_rds\_instance\_class) | The instance class to use for the RDS instance | `string` | `"db.t4g.large"` | no |
| <a name="input_gitlab_s3_bucket_force_destroy"></a> [gitlab\_s3\_bucket\_force\_destroy](#input\_gitlab\_s3\_bucket\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_gitlab_service_account_names"></a> [gitlab\_service\_account\_names](#input\_gitlab\_service\_account\_names) | List of service accounts to create for GitLab | `list(string)` | <pre>[<br>  "gitlab-gitaly",<br>  "gitlab-sidekiq",<br>  "gitlab-toolbox",<br>  "gitlab-gitlab-exporter",<br>  "gitlab-registry",<br>  "gitlab-geo-logcursor",<br>  "gitlab-migrations",<br>  "gitlab-webservice",<br>  "gitlab-mailroom",<br>  "gitlab-gitlab-shell"<br>]</pre> | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for IAM roles | `string` | `null` | no |
| <a name="input_jira_db_idenitfier_prefix"></a> [jira\_db\_idenitfier\_prefix](#input\_jira\_db\_idenitfier\_prefix) | The prefix to use for the RDS instance identifier | `string` | `"jira-db"` | no |
| <a name="input_jira_db_name"></a> [jira\_db\_name](#input\_jira\_db\_name) | Name of the Jira database. | `string` | `"jiradb"` | no |
| <a name="input_jira_kms_key_alias"></a> [jira\_kms\_key\_alias](#input\_jira\_kms\_key\_alias) | KMS Key Alias name prefix | `string` | `"jira"` | no |
| <a name="input_jira_rds_instance_class"></a> [jira\_rds\_instance\_class](#input\_jira\_rds\_instance\_class) | The instance class to use for the RDS instance | `string` | `"db.t4g.large"` | no |
| <a name="input_keycloak_enabled"></a> [keycloak\_enabled](#input\_keycloak\_enabled) | Enable Keycloak dedicated nodegroup | `bool` | `false` | no |
| <a name="input_kms_key_deletion_window"></a> [kms\_key\_deletion\_window](#input\_kms\_key\_deletion\_window) | Waiting period for scheduled KMS Key deletion. Can be 7-30 days. | `number` | `7` | no |
| <a name="input_metrics_server"></a> [metrics\_server](#input\_metrics\_server) | Metrics Server config for aws-ia/eks-blueprints-addon/aws | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name, e.g. 'app' or 'jenkins' | `string` | `"narwhal-delivery-iac-swf"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `"du"` | no |
| <a name="input_num_azs"></a> [num\_azs](#input\_num\_azs) | The number of AZs to use | `number` | `3` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | name prefix to prepend to most resources, if not defined, created as: 'namespace-stage-name' | `string` | `""` | no |
| <a name="input_reclaim_policy"></a> [reclaim\_policy](#input\_reclaim\_policy) | Reclaim policy for EFS storage class, valid options are Delete and Retain | `string` | `"Delete"` | no |
| <a name="input_recovery_window"></a> [recovery\_window](#input\_recovery\_window) | Number of days to retain secret before permanent deletion in Secrets Manager | `number` | `30` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | A list of secondary CIDR blocks for the VPC | `list(string)` | `[]` | no |
| <a name="input_secrets_store_csi_driver"></a> [secrets\_store\_csi\_driver](#input\_secrets\_store\_csi\_driver) | k8s Secret Store CSI Driver Helm Chart config | `any` | `{}` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | If true, a single NAT Gateway will be created | `bool` | `false` | no |
| <a name="input_slack_notification_enabled"></a> [slack\_notification\_enabled](#input\_slack\_notification\_enabled) | enable slack notifications for password rotation function. If enabled a slack webhook url will also need to be provided for this to work | `bool` | `false` | no |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | value | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `"test"` | no |
| <a name="input_storageclass_reclaim_policy"></a> [storageclass\_reclaim\_policy](#input\_storageclass\_reclaim\_policy) | Reclaim policy for gp3 storage class, valid options are Delete and Retain | `string` | `"Delete"` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | name suffix to append to most resources, if not defined, randomly generated | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | This needs to be a list of users that will be on your ec2 instances that need password changes. | `list(string)` | `[]` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_zarf_s3_bucket_force_destroy"></a> [zarf\_s3\_bucket\_force\_destroy](#input\_zarf\_s3\_bucket\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
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
