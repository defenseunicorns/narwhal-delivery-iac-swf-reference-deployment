locals {
  uds_config_secret_name = join("-", compact([local.prefix, "uds-config", local.suffix]))
}

resource "local_sensitive_file" "uds_config" {
  filename = "uds-config.yaml"
  content  = <<EOY
shared:
  bucket_suffix: "-${local.suffix}"

variables:
  zarf-init-s3-backend:
    registry_pc_enabled: "false"
    registry_hpa_min: "2"
    registry_pvc_enabled: "false"
    registry_service_account_name: "docker-registry-sa"
    registry_create_service_account: "true"
    registry_service_account_annotations: "eks.amazonaws.com/role-arn: ${module.zarf.irsa_role_arn}"
    registry_extra_envs: |
      - name: REGISTRY_STORAGE
        value: s3
      - name: REGISTRY_STORAGE_S3_REGION
        value: "${var.region}"
      - name: REGISTRY_STORAGE_S3_BUCKET
        value: "${module.zarf.zarf_registry_s3_bucket_name}"
  swf-deps-aws:
    gitlab_db_password: "${random_password.gitlab_db_password.result}"
    confluence_db_password: "${random_password.confluence_db_password.result}"
    jira_db_password: "${random_password.jira_db_password.result}"
    redis_password: "${random_password.gitlab_elasticache_password.result}"
    region: "${var.region}"
  gitlab:
    gitlab_db_endpoint: "${element(split(":", module.gitlab_db.db_instance_endpoint), 0)}"
    gitlab_redis_endpoint: "${aws_elasticache_replication_group.gitlab_redis.primary_endpoint_address}"
    gitlab_redis_scheme: "rediss"
    registry_role_arn: "${module.gitlab_irsa_s3.bucket_roles["gitlab-registry"].iam_role_arn}"
    sidekiq_role_arn: "${module.gitlab_irsa_s3.bucket_roles["gitlab-sidekiq"].iam_role_arn}"
    webservice_role_arn: "${module.gitlab_irsa_s3.bucket_roles["gitlab-webservice"].iam_role_arn}"
    toolbox_role_arn: "${module.gitlab_irsa_s3.bucket_roles["gitlab-toolbox"].iam_role_arn}"
  confluence:
    confluence_db_endpoint: "${element(split(":", module.confluence_db.db_instance_endpoint), 0)}"
  jira:
    jira_db_endpoint: "${element(split(":", module.jira_db.db_instance_endpoint), 0)}"
EOY
}

resource "aws_secretsmanager_secret" "uds_config" {
  name                    = local.uds_config_secret_name
  description             = "uds-swf-${var.stage} UDS Config file"
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "uds_config_value" {
  depends_on    = [aws_secretsmanager_secret.uds_config, local_sensitive_file.uds_config]
  secret_id     = aws_secretsmanager_secret.uds_config.id
  secret_string = local_sensitive_file.uds_config.content
}

# data "aws_iam_role" "bastion-role" {
#   name = "${var.stage}-bastion"
# }

# resource "aws_iam_role_policy" "read_secret" {
#   name = "${var.stage}-read-uds-swf-secret"
#   role = data.aws_iam_role.bastion-role.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "secretsmanager:GetResourcePolicy",
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret",
#           "secretsmanager:ListSecretVersionIds"
#         ]
#         Effect   = "Allow"
#         Resource = aws_secretsmanager_secret.uds_config.arn
#       },
#       {
#         Effect   = "Allow"
#         Action   = "secretsmanager:ListSecrets"
#         Resource = "*"
#       },
#     ]
#   })
# }
