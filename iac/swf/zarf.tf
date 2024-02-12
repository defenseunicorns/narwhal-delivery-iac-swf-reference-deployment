module "zarf" {
  source = "./modules/zarf"

  prefix = local.prefix
  suffix = local.suffix

  namespace = var.namespace
  stage     = var.stage
  name      = "zarf-registry"

  s3_bucket_name_use_prefix = true
  s3_bucket_name_prefix     = "${local.prefix}-zarf-registry"
  s3_bucket_lifecycle_rules = []

  oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}
