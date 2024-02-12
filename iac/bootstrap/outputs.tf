output "account_tfstate_backend_s3_bucket_id" {
  value       = module.tfstate_backend.s3_bucket_id
  description = "tfstate backend S3 bucket ID"
}

output "account_tfstate_backend_dynamodb_table_name" {
  value       = module.tfstate_backend.dynamodb_table_name
  description = "tfstate backend DynamoDB table name"
}

output "account_tfstate_backend_dynamodb_table_id" {
  value       = module.tfstate_backend.dynamodb_table_id
  description = "tf state backend DynamoDB table ID"
}
