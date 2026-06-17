variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "Optional local AWS CLI profile. Leave null in CI so environment credentials are used."
  type        = string
  default     = null
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
  default     = null
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the EC2 instance. Use a restricted CIDR for real environments."
  type        = string
  default     = null
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
