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

  dynamic "ingress" {
    for_each = local.app_ingress_ports

    content {
      description     = "Allow traffic from web server SG"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.web_server_sg.id]
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

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security group for Terraform monitoring"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow traffic from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  dynamic "ingress" {
    for_each = local.monitoring_ingress_ports

    content {
      description     = "Allow Grafana/Prometheus UI from web (nginx proxy)"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.web_server_sg.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------
# Chiều B (SCRAPE): Prometheus (monitoring SG) hút node_exporter cổng 9100
# trên web & app. Khai báo tách rời để tránh dependency cycle web<->monitoring
# (monitoring_sg đã tham chiếu web_server_sg inline ở block dynamic phía trên).
# ---------------------------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "web_node_exporter_from_monitoring" {
  security_group_id            = aws_security_group.web_server_sg.id
  referenced_security_group_id = aws_security_group.monitoring_sg.id
  description                  = "node_exporter scrape from Prometheus"
  from_port                    = 9100
  to_port                      = 9100
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_node_exporter_from_monitoring" {
  security_group_id            = aws_security_group.app_sg.id
  referenced_security_group_id = aws_security_group.monitoring_sg.id
  description                  = "node_exporter scrape from Prometheus"
  from_port                    = 9100
  to_port                      = 9100
  ip_protocol                  = "tcp"
}
