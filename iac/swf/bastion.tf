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
  source = "git::https://github.com/defenseunicorns/terraform-aws-bastion.git?ref=v0.0.11"

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
  session_log_bucket_name_prefix = "${local.bastion_name}-sessionlogs"
  kms_key_arn                    = aws_kms_key.default.arn
  ssh_user                       = var.bastion_ssh_user
  ssh_password                   = var.bastion_ssh_password
  assign_public_ip               = false
  enable_log_to_s3               = true
  enable_log_to_cloudwatch       = true
  tenancy                        = var.bastion_tenancy
  zarf_version                   = var.zarf_version
  permissions_boundary           = var.iam_role_permissions_boundary
  tags = merge(
    local.tags,
  { Function = "bastion-ssm" })
}

module "password_lambda" {

  source      = "git::https://github.com/defenseunicorns/terraform-aws-lambda.git//modules/password-rotation?ref=v0.0.3"
  region      = var.region
  random_id   = lower(random_id.default.hex)
  name_prefix = local.prefix
  users       = var.users
  # Add any additional instances you want the function to run against here
  instance_ids                    = [module.bastion.instance_id]
  cron_schedule_password_rotation = var.cron_schedule_password_rotation
  slack_notification_enabled      = var.slack_notification_enabled
  slack_webhook_url               = var.slack_webhook_url
}
