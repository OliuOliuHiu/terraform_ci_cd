resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Bastion security group for Terraform lab"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH from allowed CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "terraform-lab-sg"
  description = "Security group for Terraform lab"
  vpc_id      = aws_vpc.main.id


  dynamic "ingress" {
    for_each = local.web_ingress_rules

    content {
      description = ingress.key

      from_port = ingress.value.port
      to_port   = ingress.value.port

      protocol = "tcp"

      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  ingress {
    description     = "Allow traffic from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for Terraform app"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow traffic from web server SG"
    from_port       = local.app_port
    to_port         = local.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_sg.id]
  }
  ingress {
    description     = "Allow traffic from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
