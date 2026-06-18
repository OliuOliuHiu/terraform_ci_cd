variable "aws_region" {
  description = "AWS region for the Terraform backend resources."
  type        = string
}

variable "project_name" {
  description = "Project name for backend resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment, for example dev, staging, or prod."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}
