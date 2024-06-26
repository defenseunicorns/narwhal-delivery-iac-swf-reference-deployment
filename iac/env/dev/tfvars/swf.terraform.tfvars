###########################################################
#################### VPC Config ###########################

vpc_cidr              = "10.200.0.0/16"
secondary_cidr_blocks = ["100.64.0.0/16"] #https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/
enable_public_subnets = true
single_nat_gateway    = true
enable_nat_gateway    = true


# new_bits is added to the cidr of vpc_cidr to chunk the subnets up
# public-a - 10.200.0.0/22 - 1,022 hosts
# public-b - 10.200.4.0/22 - 1,022 hosts
# public-c - 10.200.8.0/22 - 1,022 hosts
# private-a - 10.200.12.0/22 - 1,022 hosts
# private-b - 10.200.16.0/22 - 1,022 hosts
# private-c - 10.200.20.0/22 - 1,022 hosts
# database-a - 10.200.24.0/27 - 30 hosts
# database-b - 10.200.24.32/27 - 30 hosts
# database-c - 10.200.24.64/27 - 30 hosts
vpc_subnets = [
  {
    name     = "public-a"
    new_bits = 6
  },
  {
    name     = "public-b"
    new_bits = 6
  },
  {
    name     = "public-c"
    new_bits = 6
  },
  {
    name     = "private-a"
    new_bits = 6
  },
  {
    name     = "private-b"
    new_bits = 6
  },
  {
    name     = "private-c"
    new_bits = 6
  },
  {
    name     = "database-a"
    new_bits = 11
  },
  {
    name     = "database-b"
    new_bits = 11
  },
  {
    name     = "database-c"
    new_bits = 11
  },
]

recovery_window = 0 # secretsmanager secrets

###########################################################
################## Bastion Config #########################

bastion_ssh_user     = "ec2-user" # local user in bastion used to ssh
bastion_ssh_password = "my-password"
# renovate: datasource=github-tags depName=defenseunicorns/zarf
zarf_version = "v0.32.4"

###########################################################
#################### EKS Config ###########################
# renovate: datasource=endoflife-date depName=amazon-eks versioning=loose extractVersion=^(?<version>.*)-eks.+$
cluster_version                = "1.29"
cluster_endpoint_public_access = true

###########################################################
############## Big Bang Dependencies ######################

keycloak_enabled = false # provisions keycloak dedicated nodegroup

# #################### EKS Addons #########################
# add other "eks native" marketplace addons and configs to this list
cluster_addons = {
  vpc-cni = {
    most_recent          = true
    before_compute       = true
    configuration_values = <<-JSON
      {
        "env": {
          "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
          "ENABLE_PREFIX_DELEGATION": "true",
          "ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
          "WARM_PREFIX_TARGET": "1",
          "ANNOTATE_POD_IP": "true",
          "POD_SECURITY_GROUP_ENFORCING_MODE": "standard"
        },
        "enableNetworkPolicy": "true",
        "nodeAgent": {
          "enablePolicyEventLogs": "true",
          "enableCloudWatchLogs": "false"
        }
      }
    JSON
  }
  coredns = {
    most_recent = true
    timeouts = {
      create = "20m"
      delete = "10m"
    }
  }
  kube-proxy = {
    most_recent = true
    timeouts = {
      create = "20m"
      delete = "10m"
    }
  }
  aws-ebs-csi-driver = {
    most_recent = true
    timeouts = {
      create = "20m"
      delete = "10m"
    }
  }
  # consider using '"useFIPS": "true"' under configuration_values for aws_efs_csi_driver
  aws-efs-csi-driver = {
    most_recent = true
    timeouts = {
      create = "20m"
      delete = "10m"
    }
  }
}

#################### EKS Access Policies ###########################
enable_cluster_creator_admin_permissions = true
admin_users                              = []
enable_admin_roles_prefix_or_suffix      = false
admin_roles                              = []

#################### Blueprints addons ###################
# stages things in AWS for the cluster, values staged in SSM, consumed by zarf packages
enable_amazon_eks_aws_efs_csi_driver = true
enable_amazon_eks_aws_ebs_csi_driver = true
enable_aws_node_termination_handler  = true
enable_cluster_autoscaler            = true
enable_aws_load_balancer_controller  = true

################# Lambda Password Rotation ##################
# Add users that will be on your ec2 instances.
users = ["ec2-user"]
# notification_webhook_secret_id = "slack-webhook-secret" # secretsmanager secret

###########################################################
################ Zarf AWS Dependencies ####################

zarf_s3_bucket_force_destroy = true

#############################################################
################ Gitlab AWS Dependencies ####################
gitlab_s3_bucket_force_destroy     = true
velero_s3_bucket_force_destroy     = true
mattermost_s3_bucket_force_destroy = true
loki_s3_bucket_force_destroy       = true

# gitaly_pvc_size = ""

# gitaly_pv_match_labels = []

##############################################################
######################### Jenkins ############################

# jenkins_persistence_existing_claim = ""

###########################################################
######################### Jira ############################

# jira_local_home_pvc_size = ""

#################################################################
######################### Confluence ############################

# confluence_local_home_pvc_size = ""

###########################################################
######################### Loki ############################

# loki_pvc_size = ""

#################################################################
######################### Prometheus ############################

# prometheus_pvc_size = ""

# mattermost_db_snapshot = ""

##################################################################
######################### Artifactory ############################

# artifactory_storage_type = "awsS3V3"
# artifactory_bucket_names = ["artifactory"]
