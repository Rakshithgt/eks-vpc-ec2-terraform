terraform {
  backend "s3" {
    bucket = "dev-642025"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
  }
}
