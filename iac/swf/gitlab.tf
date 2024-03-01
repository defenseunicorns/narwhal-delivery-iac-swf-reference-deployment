locals {
  gitlab_db_secret_name            = join("-", compact([local.prefix, "gitlab-db-secret", local.suffix]))
  gitlab_kms_key_alias_name_prefix = join("-", compact([local.prefix, var.gitlab_kms_key_alias, local.suffix]))
}

module "gitlab_s3_bucket" {
  for_each = toset(var.gitlab_bucket_names)

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v4.1.0"

  bucket        = join("-", compact([local.prefix, each.key, local.suffix]))
  force_destroy = var.gitlab_s3_bucket_force_destroy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.gitlab_kms_key.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "gitlab_kms_key" {
  source = "github.com/defenseunicorns/terraform-aws-uds-kms?ref=v0.0.2"

  kms_key_alias_name_prefix = local.gitlab_kms_key_alias_name_prefix
  kms_key_deletion_window   = 7
  kms_key_description       = "GitLab Key"
}

module "gitlab_irsa_s3" {
  source = "./modules/irsa-s3"

  stage                = var.stage
  serviceaccount_names = var.gitlab_service_account_names
  policy_name          = "gitlab"
  prefix               = local.prefix
  suffix               = local.suffix
  k8s_namespace        = var.gitlab_namespace
  bucket_names         = var.gitlab_bucket_names
  kms_key_arn          = module.gitlab_kms_key.kms_key_arn
  oidc_provider_arn    = module.eks.oidc_provider_arn
}

# RDS

resource "random_password" "gitlab_db_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "gitlab_db_secret" {
  name                    = local.gitlab_db_secret_name
  description             = "Gitlab DB authentication token"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = module.gitlab_kms_key.kms_key_arn
}

module "gitlab_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier                     = var.gitlab_db_idenitfier_prefix
  instance_use_identifier_prefix = true

  allocated_storage       = 20
  backup_retention_period = 1
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  engine               = "postgres"
  engine_version       = "15.5"
  major_engine_version = "15"
  family               = "postgres15"
  instance_class       = var.gitlab_rds_instance_class

  db_name  = var.gitlab_db_name
  username = "gitlab"
  port     = "5432"

  subnet_ids                  = module.vpc.database_subnets
  db_subnet_group_name        = module.vpc.database_subnet_group_name
  manage_master_user_password = false
  password                    = random_password.gitlab_db_password.result

  vpc_security_group_ids = [aws_security_group.gitlab_rds_sg.id]
}

resource "aws_security_group" "gitlab_rds_sg" {
  vpc_id = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "gitlab_rds_ingress" {
  security_group_id = aws_security_group.gitlab_rds_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 5432
}


# Elasticache

resource "random_password" "gitlab_elasticache_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "gitlab_elasticache_secret" {
  name                    = join("-", compact([local.prefix, "elasticache-secret", local.suffix]))
  description             = "swf-${var.stage} Elasticache authentication token"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = module.gitlab_kms_key.kms_key_arn
}

resource "aws_elasticache_replication_group" "gitlab_redis" {
  replication_group_id = join("-", compact([local.prefix, var.gitlab_elasticache_cluster_name, local.suffix]))
  description          = "Redis Replication Group for GitLab"

  subnet_group_name = aws_elasticache_subnet_group.gitlab_redis.name

  node_type            = "cache.r6g.large"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  auth_token           = random_password.gitlab_elasticache_password.result
  port                 = 6379

  num_cache_clusters = 2

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  security_group_ids = [aws_security_group.gitlab_redis_sg.id]
}

resource "aws_elasticache_subnet_group" "gitlab_redis" {
  name       = "gitlab-redis-cache-subnet"
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets, module.vpc.database_subnets)
}

resource "aws_security_group" "gitlab_redis_sg" {
  vpc_id = module.vpc.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "gitlab_redis_ingress" {
  security_group_id = aws_security_group.gitlab_redis_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 6379
}
