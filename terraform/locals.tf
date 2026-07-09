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
  app_ingress_ports = [8080, 5000, 8082]
  repo_server_ingress_ports = [8092]
  repo_server_ci_ports = [8092,2222]
  monitoring_ingress_ports = [3000, 9090]
}
