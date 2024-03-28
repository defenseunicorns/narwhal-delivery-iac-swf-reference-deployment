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

data "aws_partition" "current" {}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = var.dlm_role_name
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
  name   = var.dlm_role_name
  role   = aws_iam_role.dlm_lifecycle_role.id
  policy = data.aws_iam_policy_document.dlm_lifecycle.json
}

resource "aws_dlm_lifecycle_policy" "this" {
  description        = var.lifecycle_policy_description
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"
  tags               = merge(
    var.tags,
    {
      Name = var.dlm_role_name
    }
  )

  policy_details {
    resource_types = ["VOLUME"]

    dynamic "schedule" {
      for_each = var.schedule_details
      content {
        name = schedule.value.name

        create_rule {
          cron_expression = schedule.value.create_rule.cron_expression
        }

        retain_rule {
          count = schedule.value.retain_rule.count
        }

        copy_tags = true
      }
    }

    target_tags = var.target_tags
  }
}
