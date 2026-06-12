locals {
  ssh_allowed_cidr = var.ssh_allowed_cidr != null ? var.ssh_allowed_cidr : "${var.my_ip}/32"

  ingress_rules = {
    ssh = {
      port = 22
      cidr = local.ssh_allowed_cidr
    }

    http = {
      port = 80
      cidr = "0.0.0.0/0"
    }
  }
}
