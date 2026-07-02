locals {
  web_ingress_rules = {
    http = {
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    }

    https = {
      port        = 443
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  app_ingress_ports = [8080, 8929]
}
