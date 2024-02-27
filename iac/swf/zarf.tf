module "zarf" {
  source = "./modules/zarf"

  prefix = local.prefix
  suffix = local.suffix

  namespace = var.namespace
  stage     = var.stage
  name      = "zarf-registry"

  s3_bucket_name_use_prefix = true
  s3_bucket_name_prefix     = join("-", [local.prefix, "zarf-registry"])
  s3_bucket_lifecycle_rules = []
  s3_bucket_force_destroy   = var.zarf_s3_bucket_force_destroy

  oidc_provider_arn = module.eks.oidc_provider_arn

  tags = local.tags
}
