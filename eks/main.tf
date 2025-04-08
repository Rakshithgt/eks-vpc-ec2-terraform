resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.env}-${var.eks_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.env}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.env}-${var.eks_name}"
  version  = var.eks_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

# OIDC Provider for IRSA
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd40f94"]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  depends_on = [aws_eks_cluster.eks]
}

# VPC CNI Addon
resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.eks.name
  addon_name        = "vpc-cni"
  resolve_conflicts_on_create  = "OVERWRITE"
  resolve_conflicts_on_update  = "OVERWRITE"
  depends_on        = [aws_eks_cluster.eks]
}

# CoreDNS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.eks.name
  addon_name        = "coredns"
  addon_version     = "v1.11.1-eksbuild.4"
  resolve_conflicts_on_create  = "OVERWRITE"
  resolve_conflicts_on_update  = "OVERWRITE"
  depends_on        = [aws_eks_cluster.eks]
}

# Kube Proxy Addon
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.eks.name
  addon_name        = "kube-proxy"
  resolve_conflicts_on_create  = "OVERWRITE"
  resolve_conflicts_on_update  = "OVERWRITE"
  depends_on        = [aws_eks_cluster.eks]
}

# EBS CSI Assume Role Policy Document
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# EBS CSI Addon
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.41.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_create  = "OVERWRITE"
  resolve_conflicts_on_update  = "OVERWRITE"
  depends_on               = [
    aws_eks_cluster.eks,
    aws_iam_role.ebs_csi_role,
    aws_iam_role_policy_attachment.ebs_csi
  ]
}
