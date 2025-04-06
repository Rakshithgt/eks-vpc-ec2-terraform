variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the node group"
}

variable "eks_version" {
  type        = string
  description = "EKS cluster version"
}

variable "eks_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "env" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to attach node group"
}
