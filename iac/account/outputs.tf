output "tfstate_backend_s3_bucket_id" {
  value       = module.tfstate_backend.s3_bucket_id
  description = "tfstate backend S3 bucket ID"
}

output "tfstate_backend_dynamodb_table_name" {
  value       = module.tfstate_backend.dynamodb_table_name
  description = "tfstate backend DynamoDB table name"
}

output "tfstate_backend_dynamodb_table_id" {
  value       = module.tfstate_backend.dynamodb_table_id
  description = "tf state backend DynamoDB table ID"
}

output "terraform_backend_config" {
  value       = module.tfstate_backend.terraform_backend_config
  description = "rendered terraform backend config"
}

output "zarf_bucket_id" {
  value       = module.zarf_s3_bucket.s3_bucket_id
  description = "Zarf S3 bucket ID"
}
