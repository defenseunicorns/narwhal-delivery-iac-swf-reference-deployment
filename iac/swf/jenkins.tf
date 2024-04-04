locals {
  jenkins_dlm_role_name             = join("-", compact([local.prefix, "dlm-lifecycle-jenkins", local.suffix]))
}

module "jenkins_volume_snapshots" {
  source        = "./modules/volume-snapshot"
  dlm_role_name = local.jenkins_dlm_role_name

  schedule_details = [{
    name = "Daily"
    create_rule = {
      cron_expression = "cron(0 0 * * ? *)"
    }
    retain_rule = {
      count = 30
    }
    },
    {
      name = "Weekly"
      create_rule = {
        cron_expression = "cron(0 0 ? * 1 *)"
      }
      retain_rule = {
        count = 52
      }
    },
    {
      name = "Monthly"
      create_rule = {
        cron_expression = "cron(0 0 1 * ? *)"
      }
      retain_rule = {
        count = 84
      }
  }]
  target_tags = {
    NamespaceAndId = "jenkins-${lower(random_id.default.hex)}"
  }
  lifecycle_policy_description = "Policy for Jenkins volume snapshots"
  tags                         = local.tags
}
