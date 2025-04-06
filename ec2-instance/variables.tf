variable "ami_id" {
  type        = string
  description = "AMI ID for Jenkins EC2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "Key pair name for SSH access"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch the EC2 instance"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the EC2 instance"
}

variable "vpc_id" {
  description = "VPC ID for the Jenkins security group"
  type        = string
}

