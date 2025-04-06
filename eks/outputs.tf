output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "EKS Cluster API Server endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_version" {
  description = "EKS Kubernetes version"
  value       = aws_eks_cluster.eks.version
}

output "cluster_certificate_authority" {
  description = "EKS Cluster certificate authority data"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  description = "OIDC Provider URL"
  value       = aws_iam_openid_connect_provider.oidc.url
}
