locals {
  ingress_rules = {
    ssh = {
      port        = 22
      cidr_blocks = var.ssh_allowed_cidrs
    }

    http = {
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
