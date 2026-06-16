terraform {
  backend "s3" {
    bucket       = "os-k4-oliuhiu"
    key          = "lab-02-tera/dev/terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
    encrypt      = true
  }
}
