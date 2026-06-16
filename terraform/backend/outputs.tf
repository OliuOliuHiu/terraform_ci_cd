output "state_bucket_name" {
  description = "S3 bucket name for the app Terraform backend."
  value       = aws_s3_bucket.tf_state.bucket
}

output "backend_config" {
  description = "Backend config values for the app Terraform stack."
  value = {
    bucket  = aws_s3_bucket.tf_state.bucket
    key     = "lab-02-tera/${var.environment}/terraform.tfstate"
    region  = var.aws_region
    encrypt = true
  }
}
