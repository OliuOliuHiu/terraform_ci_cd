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
  public_key = var.ec2_public_key
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.public[local.azs[0]].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.public[local.azs[0]].id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.private[local.azs[0]].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-app"
  }
}


resource "aws_instance" "repo-server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.private[local.azs[1]].id
  vpc_security_group_ids = [aws_security_group.repo_server_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-repo-server"
  }
}


resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab_key.key_name
  subnet_id              = aws_subnet.private[local.azs[1]].id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-monitoring"
  }
}

resource "aws_eip" "web_server_eip" {
  domain = "vpc"
}

resource "aws_eip" "bastion_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "web_server_eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web_server_eip.id
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}
