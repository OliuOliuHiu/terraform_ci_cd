variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into the EC2 instance."
  type        = list(string)
}

variable "ec2_public_key" {
  description = "Public SSH key to register as the EC2 key pair."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "az_count" {
  description = "Number of availability zones (and public/private subnet pairs) to create"
  type        = number
  default     = 2
}
