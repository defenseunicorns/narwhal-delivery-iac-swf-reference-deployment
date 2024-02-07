locals {
  cluster_security_group_additional_rules = merge(
    { ingress_bastion_to_cluster = local.ingress_bastion_to_cluster },
    #other rules here
  )

  # self managed node groups settings
  self_managed_node_group_defaults = {
    iam_role_permissions_boundary          = var.iam_role_permissions_boundary
    instance_type                          = null # conflicts with instance_requirements settings
    update_launch_template_default_version = true

    use_mixed_instances_policy = true

    instance_requirements = {
      allowed_instance_types = ["m7i.4xlarge", "m6a.4xlarge", "m5a.4xlarge"] #this should be adjusted to the appropriate instance family if reserved instances are being utilized
      memory_mib = {
        min = 64000
      }
      vcpu_count = {
        min = 16
      }
    }

    placement = {
      tenancy = var.eks_worker_tenancy
    }

    pre_bootstrap_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

    post_userdata = <<-EOT
        echo "Bootstrap successfully completed! You can further apply config or install to run after bootstrap if needed"
      EOT

    # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
    # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
    bootstrap_extra_args = "--use-max-pods false"

    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore      = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      AmazonElasticFileSystemFullAccess = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    }

    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = merge(
      local.tags,
      {
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    })

    metadata_options = {
      #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#metadata-options
      http_endpoint               = "enabled"
      http_put_response_hop_limit = 2
      http_tokens                 = "optional" # set to "enabled" to enforce IMDSv2, default for upstream terraform-aws-eks module
    }

    tags = {
      subnet_type = "private",
      cluster     = local.cluster_name
    }
  }

  mission_app_self_mg_node_group = {
    bigbang_ng = {
      subnet_ids   = module.vpc.private_subnets
      min_size     = 3
      max_size     = 5
      desired_size = 3

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 50
            volume_type = "gp3"
          }
        }
      }
    }
  }

  keycloak_self_mg_node_group = {
    keycloak_ng_sso = {
      platform      = "bottlerocket"
      ami_id        = data.aws_ami.eks_default_bottlerocket.id
      instance_type = null # conflicts with instance_requirements settings
      min_size      = 2
      max_size      = 2
      desired_size  = 2
      key_name      = var.keycloak_enabled ? module.key_pair[0].key_pair_name : null

      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"

        [settings.kubernetes.node-labels]
        label1 = "sso"
        label2 = "bb-core"

        [settings.kubernetes.node-taints]
        dedicated = "experimental:PreferNoSchedule"
        special = "true:NoSchedule"
      EOT
    }
  }

  self_managed_node_groups = merge(
    local.mission_app_self_mg_node_group,
    var.keycloak_enabled ? local.keycloak_self_mg_node_group : {}
  )

}

module "ssm_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.0"

  create = var.create_ssm_parameters

  description = "KMS key for SecureString SSM parameters"

  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  computed_aliases = {
    ssm = {
      name = "${local.kms_key_alias_name_prefix}-ssm"
    }
  }

  key_statements = [
    {
      sid    = "SSM service access"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["ssm.amazonaws.com"]
        }
      ]
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
    }
  ]

  tags = local.tags
}

locals {
  ssm_parameter_key_arn = var.create_ssm_parameters ? module.ssm_kms_key.key_arn : ""

  access_entries = merge(
    var.access_entries,
    { bastion = {
      principal_arn = module.bastion.bastion_role_arn
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    } },
  )
}

module "eks" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-eks.git?ref=v0.0.14"

  name                                     = local.cluster_name
  aws_region                               = var.region
  azs                                      = module.vpc.azs
  vpc_id                                   = module.vpc.vpc_id
  private_subnet_ids                       = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.private_subnets
  iam_role_permissions_boundary            = var.iam_role_permissions_boundary
  cluster_security_group_additional_rules  = local.cluster_security_group_additional_rules
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_private_access          = true
  vpc_cni_custom_subnet                    = module.vpc.intra_subnets
  aws_admin_usernames                      = var.aws_admin_usernames
  cluster_version                          = var.cluster_version
  cidr_blocks                              = module.vpc.private_subnets_cidr_blocks
  eks_use_mfa                              = var.eks_use_mfa
  dataplane_wait_duration                  = var.dataplane_wait_duration
  access_entries                           = local.access_entries
  authentication_mode                      = var.authentication_mode
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  ######################## Self Managed Node Group ###################################
  self_managed_node_group_defaults = local.self_managed_node_group_defaults
  self_managed_node_groups         = local.self_managed_node_groups

  tags = local.tags



  #---------------------------------------------------------------
  #"native" EKS Add-Ons
  #---------------------------------------------------------------

  cluster_addons = var.cluster_addons

  #---------------------------------------------------------------
  # EKS Blueprints - blueprints curated helm charts
  #---------------------------------------------------------------
  create_kubernetes_resources = var.create_kubernetes_resources
  create_ssm_parameters       = var.create_ssm_parameters
  ssm_parameter_key_arn       = local.ssm_parameter_key_arn

  # AWS EKS EBS CSI Driver
  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  enable_gp3_default_storage_class     = var.enable_gp3_default_storage_class
  storageclass_reclaim_policy          = var.storageclass_reclaim_policy

  # AWS EKS EFS CSI Driver
  enable_amazon_eks_aws_efs_csi_driver = var.enable_amazon_eks_aws_efs_csi_driver
  aws_efs_csi_driver                   = var.aws_efs_csi_driver

  reclaim_policy = var.reclaim_policy

  # AWS EKS node termination handler
  enable_aws_node_termination_handler = var.enable_aws_node_termination_handler
  aws_node_termination_handler        = var.aws_node_termination_handler

  # k8s Metrics Server
  enable_metrics_server = var.enable_metrics_server
  metrics_server        = var.metrics_server

  # k8s Cluster Autoscaler
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler        = var.cluster_autoscaler

  # AWS Load Balancer Controller
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  aws_load_balancer_controller        = var.aws_load_balancer_controller

  # k8s Secrets Store CSI Driver
  enable_secrets_store_csi_driver = var.enable_secrets_store_csi_driver
  secrets_store_csi_driver        = var.secrets_store_csi_driver
}

#---------------------------------------------------------------
#Keycloak Self Managed Node Group Dependencies
#---------------------------------------------------------------

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  count = var.keycloak_enabled ? 1 : 0

  key_name_prefix    = local.cluster_name
  create_private_key = true

  tags = local.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 2.0"

  count = var.keycloak_enabled ? 1 : 0

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases                 = ["eks/keycloak_ng_sso/ebs"]
  aliases_use_name_prefix = true

  tags = local.tags
}

resource "aws_iam_policy" "additional" {

  count = var.keycloak_enabled ? 1 : 0

  name        = "${local.cluster_name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}
