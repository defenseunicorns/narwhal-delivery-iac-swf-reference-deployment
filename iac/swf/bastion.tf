locals {
  ingress_bastion_to_cluster = {
    description              = "Bastion SG to Cluster"
    security_group_id        = module.eks.cluster_security_group_id
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    type                     = "ingress"
    source_security_group_id = try(module.bastion.security_group_ids[0], null)
  }

}

data "aws_ami" "amazonlinux2" {
  count       = 1
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*x86_64-gp2"]
  }

  owners = ["amazon"]
}

module "bastion" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-bastion.git?ref=v0.0.16"

  enable_bastion_terraform_permissions = true

  ami_id        = data.aws_ami.amazonlinux2[0].id
  instance_type = var.bastion_instance_type
  root_volume_config = {
    volume_type = "gp3"
    volume_size = "20"
    encrypted   = true
  }
  name                           = local.bastion_name
  vpc_id                         = module.vpc.vpc_id
  subnet_id                      = module.vpc.private_subnets[0]
  region                         = var.region
  access_logs_bucket_name        = aws_s3_bucket.access_log_bucket.id
  session_log_bucket_name_prefix = local.bastion_name
  kms_key_arn                    = aws_kms_key.default.arn
  ssh_user                       = var.bastion_ssh_user
  secrets_manager_secret_id      = module.password_lambda.secrets_manager_secret_id
  assign_public_ip               = false
  enable_log_to_s3               = true
  enable_log_to_cloudwatch       = true
  tenancy                        = var.bastion_tenancy
  zarf_version                   = var.zarf_version
  permissions_boundary           = var.iam_role_permissions_boundary

  bastion_instance_tags = {
    "Password-Rotation" = "enabled"
  }

  tags = merge(
    local.tags
  )

}

### fetch secretsmanager secret for the notifcation webhook
data "aws_secretsmanager_secret" "narwhal-bot-slack-webhook" {
  count = var.notification_webhook_secret_id != "" ? 1 : 0
  name  = var.notification_webhook_secret_id
}

module "password_lambda" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-lambda.git//modules/password-rotation?ref=v0.0.5"
  region = var.region
  suffix = lower(random_id.default.hex)
  prefix = local.prefix
  users  = var.users
  lambda_additional_policy_statements = {
    webhook_secret_fetcher = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [data.aws_secretsmanager_secret.narwhal-bot-slack-webhook[0].arn]
    }
  }

  notification_webhook_secret_id = data.aws_secretsmanager_secret.narwhal-bot-slack-webhook[0].arn
  rotation_tag_key               = "Password-Rotation"
  rotation_tag_value             = "enabled"
}
