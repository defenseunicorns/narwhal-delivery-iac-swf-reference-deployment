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

  bastion_log_group_name = join("-", compact([local.prefix, var.bastion_log_group_name, local.suffix]))
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

resource "aws_ssm_parameter" "cloudwatch_configuration_file" { # Create a cloudwatch agent configuration file that will be used to configure the cloudwatch agent on the bastion host
  # checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK" -- There is no sensitive data in this SSM parameter

  name = "AmazonCloudWatch-linux-${local.bastion_name}"
  type = "SecureString"

  value = jsonencode({
    "agent" : {
      "metrics_collection_interval" : var.bastion_cloudwatch_log_retention_days,
      "run_as_user" : "root"
    },
    "logs" : {
      "logs_collected" : {
        "files" : {
          "collect_list" : [
            {
              "file_path" : "/root/.bash_history",
              "log_group_name" : local.bastion_log_group_name
              "log_stream_name" : "command-history/root-user/{instance_id}", # {instance_id} natively set by agent
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/home/ec2-user/.bash_history",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "command-history/ec2-user/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/home/ssm-user/.bash_history",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "command-history/ssm-user/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/amazon/ssm/amazon-ssm-agent.log",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "logins/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/messages",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/boot.log*",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/secure",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/messages",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/cron*",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/cloud-init-output.log",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/dmesg",
              "log_group_name" : local.bastion_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.bastion_cloudwatch_log_retention_days
            },
          ]
        }
      }
    },
    "metrics" : {
      "aggregation_dimensions" : [
        [
          "InstanceId"
        ]
      ],

      "metrics_collected" : {
        "collectd" : {
          "metrics_aggregation_interval" : var.bastion_cloudwatch_log_retention_days
        },
        "cpu" : {
          "measurement" : [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval" : var.bastion_cloudwatch_log_retention_days,
          "resources" : [
            "*"
          ],
          "totalcpu" : false
        },
        "disk" : {
          "measurement" : [
            "used_percent",
            "inodes_free"
          ],
          "metrics_collection_interval" : var.bastion_cloudwatch_log_retention_days,
          "resources" : [
            "*"
          ]
        },
        "diskio" : {
          "measurement" : [
            "io_time"
          ],
          "metrics_collection_interval" : var.bastion_cloudwatch_log_retention_days,
          "resources" : [
            "*"
          ]
        },
        "mem" : {
          "measurement" : [
            "mem_used_percent"
          ],
          "metrics_collection_interval" : var.bastion_cloudwatch_log_retention_days
        },
        "statsd" : {
          "metrics_aggregation_interval" : var.bastion_cloudwatch_log_retention_days,
          "metrics_collection_interval" : 10,
          "service_address" : ":8125"
        },
        "swap" : {
          "measurement" : [
            "swap_used_percent"
          ],
          "metrics_collection_interval" : var.bastion_cloudwatch_log_retention_days
        }
      }
    }
  })
}

module "bastion" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-bastion.git?ref=v0.0.17"

  enable_bastion_terraform_permissions = true

  ami_id        = data.aws_ami.amazonlinux2[0].id
  instance_type = var.bastion_instance_type
  root_volume_config = {
    volume_type = "gp3"
    volume_size = "20"
    encrypted   = true
  }
  name                      = local.bastion_name
  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.private_subnets[0]
  region                    = var.region
  ssh_user                  = var.bastion_ssh_user
  secrets_manager_secret_id = module.password_lambda.secrets_manager_secret_id
  assign_public_ip          = false
  enable_log_to_cloudwatch  = true
  tenancy                   = var.bastion_tenancy
  zarf_version              = var.zarf_version
  permissions_boundary      = var.iam_role_permissions_boundary

  bastion_instance_tags = {
    "Password-Rotation" = "enabled"
  }

  tags = merge(
    local.tags
  )

}

### fetch secretsmanager secret for the notifcation webhook
data "aws_secretsmanager_secret" "notification-webhook" {
  count = var.notification_webhook_secret_id != "" ? 1 : 0
  name  = var.notification_webhook_secret_id
}

locals {
  webhook_secret_fetcher_policy = var.notification_webhook_secret_id != "" ? {
    "webhook_secret_fetcher" = {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [try(data.aws_secretsmanager_secret.notification-webhook[0].arn, "")]
    }
  } : {}

  local_lambda_additional_policy_statements = merge(
    local.webhook_secret_fetcher_policy
  )
}

module "password_lambda" {
  source                              = "git::https://github.com/defenseunicorns/terraform-aws-lambda.git//modules/password-rotation?ref=v0.0.7"
  region                              = var.region
  suffix                              = lower(random_id.default.hex)
  prefix                              = local.prefix
  users                               = var.users
  lambda_additional_policy_statements = local.local_lambda_additional_policy_statements

  notification_webhook_secret_id = try(data.aws_secretsmanager_secret.notification-webhook[0].arn, null)
  rotation_tag_key               = "Password-Rotation"
  rotation_tag_value             = "enabled"
}
