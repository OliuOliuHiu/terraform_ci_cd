terraform {
  backend "s3" {
    bucket = "os-k4-oliuhiu"
    key = "lab-02-terra/dev/terraform.tfstate"
    region = "ap-southeast-2"
    use_lockfile = true
    encrypt = true
    profile = "terraform"
  }
}
