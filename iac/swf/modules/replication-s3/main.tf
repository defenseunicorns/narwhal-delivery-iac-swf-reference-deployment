resource "random_id" "default" {
  byte_length = 2
}

locals {
  # If 'var.prefix' is explicitly null, allow it to be empty
  # If 'var.prefix' is an empty string, generate a prefix
  # If 'var.prefix' is neither null nor an empty string, assign the value of 'var.prefix' itself
  prefix = var.prefix == null ? "" : (
    var.prefix == "" ? join("-", compact([var.namespace, var.stage, var.policy_name])) :
    var.prefix
  )

  # If 'var.suffix' is null, assign an empty string
  # If 'var.suffix' is an empty string, assign a randomly generated hexadecimal value
  # If 'var.suffix' is neither null nor an empty string, assign the value of 'var.suffix' itself
  suffix = var.suffix == null ? "" : (
    var.suffix == "" ? lower(random_id.default.hex) :
    var.suffix
  )

  unique_name = join("-", compact([local.prefix, var.policy_name, "replication", local.suffix]))
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = local.unique_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [var.source_bucket_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${var.source_bucket_arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${var.destination_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = local.unique_name
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # provider = aws.central
  # Must have bucket versioning enabled first
  # depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = var.source_bucket_name

  rule {
    id = local.unique_name

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = var.destination_bucket_arn
      storage_class = "GLACIER_IR"
      encryption_configuration {
        replica_kms_key_id = var.kms_key_arn
      }
    }

    filter {}

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    status = "Enabled"
  }
}
