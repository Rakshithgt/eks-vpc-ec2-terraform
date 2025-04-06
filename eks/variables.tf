variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster."
}

variable "eks_name" {
  type        = string
  description = "EKS cluster name."
}

variable "eks_version" {
  type        = string
  description = "EKS version."
}

variable "env" {
  type        = string
  description = "Environment."
}
