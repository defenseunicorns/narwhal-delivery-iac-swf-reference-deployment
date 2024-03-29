output "irsa_role_arn" {
  value       = try(module.zarf_irsa_role[0].iam_role_arn)
  description = "zarf IRSA role ARN"
}

output "irsa_k8s_sa_name" {
  value       = "docker-registry-sa"
  description = "zarf IRSA k8s service account name in k8s"
}

output "zarf_registry_s3_bucket_name" {
  value       = module.s3_bucket.s3_bucket_id
  description = "zarf registry S3 bucket name"
}
