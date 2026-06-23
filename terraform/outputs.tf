output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${aws_key_pair.lab_key.key_name} ubuntu@${aws_eip.web_server_eip.public_ip}"
}

output "web_access_url" {
  description = "URL to access the web server on the EC2 instance"
  value       = "http://${aws_eip.web_server_eip.public_ip}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.lab.bucket
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.web_server_eip.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.lab_instance.id
}
