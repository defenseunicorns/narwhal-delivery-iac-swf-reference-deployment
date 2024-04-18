locals {
  uds_config_secret_name      = join("-", compact([local.prefix, "uds-config", local.suffix]))
  uds_config_output_path      = var.uds_config_output_path != "" ? var.uds_config_output_path : "../env/${var.stage}/uds"
  uds_config_output_file_name = var.uds_config_output_file_name != "" ? var.uds_config_output_file_name : "uds-config.yaml"
  min_node_count              = sum([for group in local.self_managed_node_groups : group["min_size"]])
}


#template comments
# roles: loop through the list of service account names and create a role for each, replacing dashes with underscores and removing the gitlab- prefix
# buckets: loop through the list of bucket names and create a variable for each, replacing dashes with underscores and removing the gitlab- prefix
resource "local_sensitive_file" "uds_config" {
  filename = "${local.uds_config_output_path}/${local.uds_config_output_file_name}"
  content  = <<EOY
variables:
  core:
    ISTIOD_AUTOSCALE_MIN: "${local.min_node_count}"
    ISTIOD_AUTOSCALE_MAX: "${local.min_node_count + 4}"
    KC_DB_PASSWORD: "${random_password.keycloak_db_password.result}"
    KC_DB_HOST: "${element(split(":", module.keycloak_db.db_instance_endpoint), 0)}"
    VELERO_ROLE_ARN: "${module.velero_irsa_s3.irsa_role[var.velero_service_account_names[0]].iam_role_arn}"
    # https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/backupstoragelocation.md
    VELERO_BACKUP_STORAGE_LOCATION:
      - name: default
        provider: aws
        bucket: "${module.velero_s3_bucket[var.velero_bucket_names[0]].s3_bucket_id}"
        config:
          region: "${var.region}"
          kmsKeyId: "${module.velero_kms_key.kms_key_alias}"
    # https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/volumesnapshotlocation.md
    VELERO_VOLUME_SNAPSHOT_LOCATION:
      - name: default
        provider: aws
        config:
          region: "${var.region}"
    LOKI_BACKEND_PVC_SIZE: "${var.loki_backend_pvc_size}"
    LOKI_WRITE_PVC_SIZE: "${var.loki_write_pvc_size}"
    LOKI_S3_REGION: "${var.region}"
    %{~for bucket in var.loki_bucket_names~}
    ${upper(replace(bucket, "-", "_"))}_BUCKET: "${module.loki_s3_bucket[bucket].s3_bucket_id}"
    %{~endfor~}
    LOKI_S3_ROLE_ARN: "${module.loki_irsa_s3.irsa_role[var.loki_service_account_names[0]].iam_role_arn}"
    PROMETHEUS_PVC_SIZE: "${var.prometheus_pvc_size}"
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
    REGISTRY_HPA_AUTO_SIZE: "true"
    REGISTRY_AFFINITY_CUSTOM: |
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - docker-registry
              topologyKey: kubernetes.io/hostname
    REGISTRY_TOLERATIONS: |
      - effect: NoSchedule
        key: dedicated
        operator: Exists
  storageclass:
    EBS_EXTRA_PARAMETERS: |
      tagSpecification_1: "NamespaceAndId={{ .PVCNamespace }}-${lower(random_id.default.hex)}"
      iopsPerGB: "500"
      allowAutoIOPSPerGBIncrease: "true"
      throughput: "1000"
  swf-deps-aws:
    gitlab_db_password: "${random_password.gitlab_db_password.result}"
    confluence_db_password: "${random_password.confluence_db_password.result}"
    jira_db_password: "${random_password.jira_db_password.result}"
    artifactory_db_password: "${random_password.artifactory_db_password.result}"
    artifactory_db_endpoint: "${element(split(":", module.artifactory_db.db_instance_endpoint), 0)}"
    artifactory_db_name: "${var.artifactory_db_name}"
    redis_password: "${random_password.gitlab_elasticache_password.result}"
    region: "${var.region}"
    registry_bucket: ${join("-", compact([local.prefix, "gitlab-registry", local.suffix]))}
  gitlab:
    gitlab_db_endpoint: "${element(split(":", module.gitlab_db.db_instance_endpoint), 0)}"
    gitlab_redis_endpoint: "${aws_elasticache_replication_group.gitlab_redis.primary_endpoint_address}"
    gitlab_redis_scheme: "rediss"
    %{~for role in var.gitlab_service_account_names~}
    ${replace(trimprefix(role, "gitlab-"), "-", "_")}_role_arn: "${module.gitlab_irsa_s3.irsa_role[role].iam_role_arn}"
    %{~endfor~}
    %{~for bucket in var.gitlab_bucket_names~}
    ${replace(trimprefix(bucket, "gitlab-"), "-", "_")}_bucket: "${module.gitlab_s3_bucket[bucket].s3_bucket_id}"
    %{~endfor~}
    disable_registry_redirect: "true"
    GITALY_PVC_SIZE: "${var.gitaly_pvc_size}"
%{if length(var.gitaly_pv_match_labels) > 0~}
    GITALY_PV_MATCH_LABELS:
      %{~for label in var.gitaly_pv_match_labels~}
      ${label}
      %{~endfor~}
%{endif~}
  confluence:
    confluence_db_endpoint: "${element(split(":", module.confluence_db.db_instance_endpoint), 0)}"
    CONFLUENCE_LOCAL_HOME_PVC_SIZE: "${var.confluence_local_home_pvc_size}"
  jira:
    jira_db_endpoint: "${element(split(":", module.jira_db.db_instance_endpoint), 0)}"
    JIRA_LOCAL_HOME_PVC_SIZE: "${var.jira_local_home_pvc_size}"
  mattermost:
    mattermost_db_endpoint: "${element(split(":", module.mattermost_db.db_instance_endpoint), 0)}"
    mattermost_db_password: "${random_password.mattermost_db_password.result}"
    mattermost_db_name: "${var.mattermost_db_name}"
    mattermost_bucket: "${module.mattermost_s3_bucket[var.mattermost_bucket_names[0]].s3_bucket_id}"
    mattermost_region: "${var.region}"
    mattermost_s3_endpoint: "s3.${var.region}.amazonaws.com"
    mattermost_role_arn: "${module.mattermost_irsa_s3.irsa_role[var.mattermost_service_account_names[0]].iam_role_arn}"
  jenkins:
    JENKINS_PVC_SIZE: "${var.jenkins_pvc_size}"
%{if length(var.jenkins_persistence_existing_claim) > 0~}
    JENKINS_PERSISTENCE_EXISTING_CLAIM: "${var.jenkins_persistence_existing_claim}"
%{endif~}
%{if var.artifatory_license_key_secret_id != ""}
  artifactory:
    ARTIFACTORY_LICENSE: "${var.artifatory_license_key_secret_id}"
%{endif~}
%{if var.artifactory_storage_type != "file-system"}
    %{~for bucket in var.artifactory_bucket_names~}
    ${replace(trimprefix(bucket, "artifactory-"), "-", "_")}_bucket: "${module.artifactory_s3_bucket[bucket].s3_bucket_id}"
    %{~endfor~}
    ARTIFACTORY_ENDPOINT: "s3.${var.region}.amazonaws.com"
%{endif~}
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
