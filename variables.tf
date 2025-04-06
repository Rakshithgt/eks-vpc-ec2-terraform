variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"   
}


variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_name" {
  default = "my-vpc"
}

variable "eks_name" {
  default = "my-eks"
}

variable "env" {
  default = "dev"
}

variable "nat" {
  default = "nat-gateway"
}

variable "eks_version" {
  default = "1.29"
}
