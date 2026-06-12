output "state_bucket_name" {
  description = "S3 bucket name for the app Terraform backend."
  value       = aws_s3_bucket.tf_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for the app Terraform backend lock."
  value       = aws_dynamodb_table.tf_locks.name
}

output "backend_config" {
  description = "Backend config values for the app Terraform stack."
  value = {
    bucket         = aws_s3_bucket.tf_state.bucket
    key            = "lab-02-tera/${var.environment}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.tf_locks.name
    encrypt        = true
  }
}
