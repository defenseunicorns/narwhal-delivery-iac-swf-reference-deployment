output "s3_bucket_id" {
  value       = module.tfstate_backend.s3_bucket_id
  description = "S3 bucket ID"
}

output "dynamodb_table_name" {
  value       = module.tfstate_backend.dynamodb_table_name
  description = "DynamoDB table name"
}

output "dynamodb_table_id" {
  value       = module.tfstate_backend.dynamodb_table_id
  description = "DynamoDB table ID"
}

output "zarf_bucket_id" {
  value       = module.zarf_s3_bucket.s3_bucket_id
  description = "Zarf S3 bucket ID"
}
