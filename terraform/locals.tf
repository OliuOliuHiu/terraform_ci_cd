locals {
  ingress_rules = {
    ssh = {
      port = 22
      cidr = "${var.my_ip}/32"
    }

    http = {
      port = 80
      cidr = "0.0.0.0/0"
    }
  }
}
