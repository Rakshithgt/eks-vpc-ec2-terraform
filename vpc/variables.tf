variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "vpc_name" {
  type        = string
  description = "Name for the VPC"
}

variable "nat_gateway_name" {
  type        = string
  description = "Name of the NAT Gateway"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "eks_name" {
  type        = string
  description = "EKS cluster name"
}
