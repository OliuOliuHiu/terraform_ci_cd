resource "aws_security_group" "lab_sg" {
  name        = "terraform-lab-sg"
  description = "Security group for Terraform lab"


  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.key

      from_port = ingress.value.port
      to_port   = ingress.value.port

      protocol = "tcp"

      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
