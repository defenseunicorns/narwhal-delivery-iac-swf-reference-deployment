data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "random_id" "snapshot_id" {
  byte_length = 2
}

locals {
  suffix = lower(random_id.snapshot_id.hex)
}

data "aws_partition" "current" {}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "dlm-lifecycle-role-${local.suffix}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "dlm_lifecycle" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:${data.aws_partition.current.partition}:ec2:*::snapshot/*"]
  }
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "dlm-lifecycle-policy-${local.suffix}"
  role   = aws_iam_role.dlm_lifecycle_role.id
  policy = data.aws_iam_policy_document.dlm_lifecycle.json
}

resource "aws_dlm_lifecycle_policy" "this" {
  description        = var.lifecycle_policy_description
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"
  tags_all           = var.tags


  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = var.schedule_details.name

      create_rule {
        cron_expression = var.schedule_details.create_rule.cron_expression
      }

      retain_rule {
        count = var.schedule_details.retain_rule.count
      }

      copy_tags = true
    }

    target_tags = var.target_tags
  }
}
