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

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for IAM roles"
  type        = string
  default     = null
}

variable "aws_admin_usernames" {
  description = "A list of one or more AWS usernames with authorized access to KMS and EKS resources, will automatically add the user running the terraform as an admin"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_deletion_window" {
  description = "Waiting period for scheduled KMS Key deletion. Can be 7-30 days."
  type        = number
  default     = 7
}

variable "access_log_expire_days" {
  description = "Number of days to wait before deleting access logs"
  type        = number
  default     = 30
}

variable "uds_config_output_path" {
  description = "The path to output the UDS config file when templating"
  type        = string
  default     = ""
}

variable "uds_config_output_file_name" {
  description = "The name of the UDS config file when templating"
  type        = string
  default     = ""
}

variable "enable_sqs_events_on_access_log_access" {
  description = "If true, generates an SQS event whenever on object is created in the Access Log bucket, which happens whenever a server access log is generated by any entity. This will potentially generate a lot of events, so use with caution."
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Sets deletion protection for RDS instances"
  type        = bool
  default     = false
}

###########################################################
#################### VPC Config ###########################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_subnets" {
  description = "A list of subnet objects to do subnet math things on - see https://github.com/hashicorp/terraform-cidr-subnets"
  type        = list(map(any))
  default     = [{}]
}

variable "secondary_cidr_blocks" {
  description = "A list of secondary CIDR blocks for the VPC"
  type        = list(string)
  default     = []
}

variable "num_azs" {
  description = "The number of AZs to use"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "If true, a single NAT Gateway will be created"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "If true, NAT Gateways will be created"
  type        = bool
  default     = false
}

# variable "transit_gateway_route_table_name" {
#   description = "The name of the transit gateway route table"
#   type        = string
# }

###########################################################
#################### Transit Gateway ######################
# variable "target_transit_gateway_tag_name" {
#   description = "The value of the Name tag"
#   type        = string
#   default     = "N/A"
# }

# variable "peered_transit_gateway_tag_name" {
#   description = "The value of the Name tag"
#   type        = string
#   default     = "N/A"
# }

###########################################################
#################### EKS Config ###########################
variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP`"
  type        = string
  default     = "API"
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}

variable "admin_users" {
  description = "List of IAM users to add as administrators to the EKS cluster via access entry"
  type        = list(string)
  default     = []
}

variable "admin_roles" {
  type        = list(string)
  description = "List of IAM roles to add as administrators to the EKS cluster via access entry"
  default     = []
}

variable "enable_admin_roles_prefix_or_suffix" {
  description = "Indicates whether or not to add the admin_roles with a prefix or suffix"
  type        = bool
  default     = true
}

variable "eks_worker_tenancy" {
  description = "The tenancy of the EKS worker nodes"
  type        = string
  default     = "dedicated"
}

variable "cluster_version" {
  description = "Kubernetes version to use for EKS cluster"
  type        = string
  # renovate: datasource=endoflife-date depName=amazon-eks versioning=loose extractVersion=^(?<version>.*)-eks.+$
  default = "1.29"
}

variable "cluster_endpoint_public_access" {
  description = "Whether to enable public access to the EKS cluster"
  type        = bool
  default     = false
}


variable "dataplane_wait_duration" {
  description = "The duration to wait for the EKS cluster to be ready before creating the node groups"
  type        = string
  default     = "30s"
}

variable "uds_swf_ng_name" {
  description = "Name of the UDS SWF node group"
  type        = string
  default     = "uds_ng"
}

variable "gitaly_ng_name" {
  description = "Name of the UDS SWF node group"
  type        = string
  default     = "gitaly_ng"
}

###########################################################
################## EKS Addons Config ######################

variable "cluster_addons" {
  description = <<-EOD
  Nested of eks native add-ons and their associated parameters.
  See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_add-on for supported values.
  See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf#L44-L60 for upstream example.

  to see available eks marketplace addons available for your cluster's version run:
  aws eks describe-addon-versions --kubernetes-version $k8s_cluster_version --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table
EOD
  type        = any
  default     = {}
}

variable "create_kubernetes_resources" {
  description = "If true, kubernetes resources related to non-marketplace addons to will be created"
  type        = bool
  default     = false
}

variable "create_ssm_parameters" {
  description = "Create SSM parameters for values from eks blueprints addons"
  type        = bool
  default     = true
}

#----------------AWS EBS CSI Driver-------------------------
variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable EKS Managed AWS EBS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "enable_gp3_default_storage_class" {
  description = "Enable gp3 as default storage class"
  type        = bool
  default     = false
}

variable "ebs_storageclass_reclaim_policy" {
  description = "Reclaim policy for gp3 storage class, valid options are Delete and Retain"
  type        = string
  default     = "Delete"
}

#----------------Metrics Server-------------------------
variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = false
}

variable "metrics_server" {
  description = "Metrics Server config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------AWS Node Termination Handler-------------------------
variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler add-on"
  type        = bool
  default     = false
}

variable "aws_node_termination_handler" {
  description = "AWS Node Termination Handler config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

#----------------Cluster Autoscaler-------------------------
variable "enable_cluster_autoscaler" {
  description = "Enable Cluster autoscaler add-on"
  type        = bool
  default     = false
}

variable "cluster_autoscaler" {
  description = "Cluster Autoscaler Helm Chart config"
  type        = any
  default     = {}
}

#----------------Enable_EFS_CSI-------------------------
variable "enable_amazon_eks_aws_efs_csi_driver" {
  description = "Enable EFS CSI add-on"
  type        = bool
  default     = false
}

variable "efs_storageclass_reclaim_policy" {
  description = "Reclaim policy for EFS storage class, valid options are Delete and Retain"
  type        = string
  default     = "Delete"
}

#----------------AWS Loadbalancer Controller-------------------------
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Loadbalancer Controller add-on"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller" {
  description = "AWS Loadbalancer Controller Helm Chart config"
  type        = any
  default     = {}
}

#----------------k8s Secret Store CSI Driver-------------------------
variable "enable_secrets_store_csi_driver" {
  description = "Enable k8s Secret Store CSI Driver add-on"
  type        = bool
  default     = false
}

variable "secrets_store_csi_driver" {
  description = "k8s Secret Store CSI Driver Helm Chart config"
  type        = any
  default     = {}
}

#----------------External Secrets-------------------------

variable "enable_external_secrets" {
  description = "Enable External Secrets add-on"
  type        = bool
  default     = false
}

variable "external_secrets" {
  description = "External Secrets config for aws-ia/eks-blueprints-addon/aws"
  type        = any
  default     = {}
}

variable "external_secrets_ssm_parameter_arns" {
  description = "List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:ssm:*:*:parameter/*"]
}

variable "external_secrets_secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:secretsmanager:*:*:secret:*"]
}

variable "external_secrets_kms_key_arns" {
  description = "List of KMS Key ARNs that are used by Secrets Manager that contain secrets to mount using External Secrets"
  type        = list(string)
  default     = [] # if not defined, ["arn:$partition:kms:*:*:key/*"]
}

###########################################################
################## Bastion Config #########################
variable "bastion_tenancy" {
  description = "The tenancy of the bastion"
  type        = string
  default     = "dedicated"
}

variable "bastion_instance_type" {
  description = "value for the instance type of the EKS worker nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "bastion_ssh_user" {
  description = "The SSH user to use for the bastion"
  type        = string
  default     = "ec2-user"
}

variable "zarf_version" {
  description = "The version of Zarf to use"
  type        = string
  default     = ""
}

############################################################################
####################### UDS Dependencies ########################

variable "keycloak_enabled" {
  description = "Enable Keycloak dedicated nodegroup"
  type        = bool
  default     = false
}

variable "recovery_window" {
  description = "Number of days to wait before deleting the secret"
  type        = number
  default     = 7
}

############################################################################
################## Lambda Password Rotation Config #########################

variable "users" {
  description = "This needs to be a list of users that will be on your ec2 instances that need password changes."
  type        = list(string)
  default     = []
}

variable "notification_webhook_secret_id" {
  description = "The secret id for the slack webhook, staged in secrets manager"
  type        = string
  default     = ""
}


############################################################################
################## Zarf Init AWS Dependencies #########################

variable "zarf_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

############################################################################
################## Gitlab Dependencies #########################

# Gitlab Variables

variable "gitlab_bucket_names" {
  description = "List of buckets to create for GitLab"
  type        = list(string)
  default     = ["gitlab-artifacts", "gitlab-backups", "gitlab-ci-secure-files", "gitlab-dependency-proxy", "gitlab-lfs", "gitlab-external-diffs", "gitlab-packages", "gitlab-pages", "gitlab-terraform-state", "gitlab-uploads", "gitlab-registry", "gitlab-runner-cache", "gitlab-tmp"]
}

variable "gitlab_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "gitlab_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "gitlab"
}

variable "gitlab_db_name" {
  description = "Name of the GitLab database."
  type        = string
  default     = "gitlabdb"
}

variable "gitlab_namespace" {
  description = "Namespace GitLab is deployed to"
  type        = string
  default     = "gitlab"
}

variable "gitlab_runner_namespace" {
  description = "Namespace GitLab Runner is deployed to"
  type        = string
  default     = "gitlab-runner"
}

variable "gitlab_elasticache_cluster_name" {
  description = "ElastiCache Cluster Name"
  type        = string
  default     = "gitlab"
}

variable "gitlab_db_idenitfier_prefix" {
  description = "The prefix to use for the RDS instance identifier"
  type        = string
  default     = "gitlab-db"
}

variable "gitlab_db_snapshot" {
  description = "The snapshot to restore the RDS instance from"
  type        = string
  default     = ""
}

variable "gitlab_rds_instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.large"
}

# variable "gitlab_service_account_names" {
#   description = "List of service accounts to create for GitLab"
#   type        = list(string)
#   default     = ["gitlab-gitaly", "gitlab-sidekiq", "gitlab-toolbox", "gitlab-gitlab-exporter", "gitlab-registry", "gitlab-geo-logcursor", "gitlab-migrations", "gitlab-webservice", "gitlab-mailroom", "gitlab-gitlab-shell"]
# }

variable "gitaly_pvc_size" {
  description = "Size of the gitaly pvc"
  type        = string
  default     = "50Gi"
}

variable "gitaly_pv_match_labels" {
  description = "List of labels to match the pv to"
  type        = list(string)
  default     = []
}

############################################################################
################## Confluence Dependencies #########################

# Confluence Variables

variable "confluence_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "confluence"
}

variable "confluence_db_name" {
  description = "Name of the Confluence database."
  type        = string
  default     = "confluencedb"
}

variable "confluence_db_idenitfier_prefix" {
  description = "The prefix to use for the RDS instance identifier"
  type        = string
  default     = "confluence-db"
}

variable "confluence_db_snapshot" {
  description = "The snapshot to restore the RDS instance from"
  type        = string
  default     = ""
}

variable "confluence_rds_instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.large"
}

variable "confluence_local_home_pvc_size" {
  description = "Size of the local home pvc"
  type        = string
  default     = "50Gi"
}

############################################################################
################## Jira Dependencies #########################

# Jira Variables

variable "jira_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "jira"
}

variable "jira_db_name" {
  description = "Name of the Jira database."
  type        = string
  default     = "jiradb"
}

variable "jira_db_idenitfier_prefix" {
  description = "The prefix to use for the RDS instance identifier"
  type        = string
  default     = "jira-db"
}

variable "jira_db_snapshot" {
  description = "The snapshot to restore the RDS instance from"
  type        = string
  default     = ""
}

variable "jira_rds_instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.large"
}

variable "jira_local_home_pvc_size" {
  description = "Size of the local home pvc"
  type        = string
  default     = "50Gi"
}

############################################################################
################## Artifactory Dependencies #########################

# Artifactory Variables

variable "artifactory_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "artifactory"
}

variable "artifactory_storage_type" {
  description = "Set the persistence storage type"
  type        = string
  default     = "file-system"
}

variable "artifactory_bucket_names" {
  description = "List of buckets to create for Artifactory"
  type        = list(string)
  default     = []
}

variable "artifactory_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "artifactory_service_account_names" {
  description = "List of service accounts to create for Artifactory"
  type        = list(string)
  default     = ["artifactory"]
}

variable "artifactory_namespace" {
  description = "Namespace Artifactory is deployed to"
  type        = string
  default     = "artifactory"
}

variable "artifatory_license_key_secret_id" {
  description = "The license secret for artifatory"
  type        = string
  default     = ""
}

variable "artifactory_db_name" {
  description = "Name of the artifactory database."
  type        = string
  default     = "artifactorydb"
}

variable "artifactory_db_idenitfier_prefix" {
  description = "The prefix to use for the RDS instance identifier"
  type        = string
  default     = "artifactory-db"
}

variable "artifactory_db_snapshot" {
  description = "The snapshot to restore the RDS instance from"
  type        = string
  default     = ""
}

variable "artifactory_rds_instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.large"
}

############################################################################
################## Keycloak Dependencies #########################

# Keycloak Variables

variable "keycloak_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "keycloak"
}

variable "keycloak_db_name" {
  description = "Name of the Keycloak database."
  type        = string
  default     = "keycloakdb"
}

variable "keycloak_db_idenitfier_prefix" {
  description = "The prefix to use for the RDS instance identifier"
  type        = string
  default     = "keycloak-db"
}

variable "keycloak_db_snapshot" {
  description = "The snapshot to restore the RDS instance from"
  type        = string
  default     = ""
}

variable "keycloak_rds_instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.large"
}

############################################################################
################## Mattermost Dependencies #########################

# Mattermost Variables

variable "mattermost_bucket_names" {
  description = "List of buckets to create for Mattermost"
  type        = list(string)
  default     = ["mattermost"]
}

variable "mattermost_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "mattermost_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "mattermost"
}

variable "mattermost_db_name" {
  description = "Name of the Mattermost database."
  type        = string
  default     = "mattermostdb"
}

variable "mattermost_namespace" {
  description = "Namespace Mattermost is deployed to"
  type        = string
  default     = "mattermost"
}

variable "mattermost_db_idenitfier_prefix" {
  description = "The prefix to use for the RDS instance identifier"
  type        = string
  default     = "mattermost-db"
}

variable "mattermost_db_snapshot" {
  description = "The snapshot to restore the RDS instance from"
  type        = string
  default     = ""
}

variable "mattermost_rds_instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.large"
}

variable "mattermost_service_account_names" {
  description = "List of service accounts to create for Mattermost"
  type        = list(string)
  default     = ["mattermost"]
}

############################################################################
################## Velero Dependencies #########################

# Velero Variables

variable "velero_bucket_names" {
  description = "List of buckets to create for Velero"
  type        = list(string)
  default     = ["velero"]
}

variable "velero_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "velero_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "velero"
}

variable "velero_namespace" {
  description = "Namespace Velero is deployed to"
  type        = string
  default     = "velero"
}

variable "velero_service_account_names" {
  description = "List of service accounts to create for Velero"
  type        = list(string)
  default     = ["velero-server"]
}

###########################################################
################### Jenkins Config ########################
variable "jenkins_persistence_existing_claim" {
  description = "Name of the pre-existing PVC that jenkins will be restored from"
  type        = string
  default     = ""
}

variable "jenkins_pvc_size" {
  description = "Size of the Loki backend pvc"
  type        = string
  default     = "50Gi"
}

###########################################################
################### Loki Config ########################
variable "loki_backend_pvc_size" {
  description = "Size of the Loki backend pvc"
  type        = string
  default     = "50Gi"
}
variable "loki_write_pvc_size" {
  description = "Size of the Loki write pvc"
  type        = string
  default     = "50Gi"
}

variable "loki_bucket_names" {
  description = "List of buckets to create for Loki"
  type        = list(string)
  default     = ["loki-ruler", "loki-admin", "loki-chunks"]
}

variable "loki_s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "loki_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "loki"
}

variable "loki_namespace" {
  description = "Namespace loki is deployed to"
  type        = string
  default     = "loki"
}

variable "loki_service_account_names" {
  description = "List of service accounts to create for loki"
  type        = list(string)
  default     = ["loki"]
}

##############################################################
################### Prometheus Config ########################
variable "prometheus_pvc_size" {
  description = "Size of the Prometheus pvc"
  type        = string
  default     = "50Gi"
}
