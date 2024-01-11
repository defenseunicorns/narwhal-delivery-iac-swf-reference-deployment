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

locals {
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
}
