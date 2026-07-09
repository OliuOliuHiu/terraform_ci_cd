# ---------------------------------------------------------------------------
# SSH / access helpers
# ---------------------------------------------------------------------------
output "bastion_ssh_command" {
  description = "SSH command to connect to the bastion host (SSH entry point)"
  value       = "ssh -i ${aws_key_pair.lab_key.key_name} ubuntu@${aws_eip.bastion_eip.public_ip}"
}

output "monitoring_ssh_command" {
  description = "SSH command to connect to the monitoring server (via bastion)"
  value       = "ssh -i ${aws_key_pair.lab_key.key_name} -o ProxyJump=ubuntu@${aws_eip.bastion_eip.public_ip} ubuntu@${aws_instance.monitoring.private_ip}"
}

output "web_ssh_command" {
  description = "SSH command to connect to the web server (via bastion)"
  value       = "ssh -i ${aws_key_pair.lab_key.key_name} -o ProxyJump=ubuntu@${aws_eip.bastion_eip.public_ip} ubuntu@${aws_instance.web.private_ip}"
}

output "app_ssh_command" {
  description = "SSH into the private app server by jumping through the bastion"
  value       = "ssh -i ${aws_key_pair.lab_key.key_name} -o ProxyJump=ubuntu@${aws_eip.bastion_eip.public_ip} ubuntu@${aws_instance.app.private_ip}"
}

output "repo_server_ssh_command" {
  description = "SSH into the private repo server (GitLab) by jumping through the bastion"
  value       = "ssh -i ${aws_key_pair.lab_key.key_name} -o ProxyJump=ubuntu@${aws_eip.bastion_eip.public_ip} ubuntu@${aws_instance.repo-server.private_ip}"
}

output "web_access_url" {
  description = "URL to access the nginx web server"
  value       = "http://${aws_eip.web_server_eip.public_ip}"
}

# ---------------------------------------------------------------------------
# Instance details
# ---------------------------------------------------------------------------
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_eip.bastion_eip.public_ip
}

output "web_public_ip" {
  description = "Public IP address of the web (nginx) server"
  value       = aws_eip.web_server_eip.public_ip
}

output "web_private_ip" {
  description = "Private IP of the web (nginx) server (reachable via the bastion)"
  value       = aws_instance.web.private_ip
}

output "app_private_ip" {
  description = "Private IP of the internal app server (reachable via the bastion)"
  value       = aws_instance.app.private_ip
}

output "monitoring_private_ip" {
  description = "Private IP of the monitoring server (reachable via the bastion)"
  value       = aws_instance.monitoring.private_ip
}

output "repo_server_private_ip" {
  description = "Private IP of the repo server / GitLab (reachable via the bastion)"
  value       = aws_instance.repo-server.private_ip
}

output "instance_ids" {
  description = "IDs of all EC2 instances"
  value = {
    bastion    = aws_instance.bastion.id
    web        = aws_instance.web.id
    app        = aws_instance.app.id
    monitoring = aws_instance.monitoring.id
  }
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------
output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.lab.bucket
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway (egress IP for private subnets)"
  value       = aws_eip.nat.public_ip
}
