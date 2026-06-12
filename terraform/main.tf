resource "aws_s3_bucket" "lab" {
  bucket        = "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket"
    Environment = var.environment
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "lab_key" {
  key_name   = "terraform-lab-key"
  public_key = file("${path.module}/terraform-lab-key.pub")
}

resource "aws_instance" "lab_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.lab_key.key_name
  security_groups             = [aws_security_group.lab_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  user_data                   = <<-EOF
  #!/bin/bash
  set -eux

  apt-get update -y
  apt-get install -y docker.io
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2"
  }
}
