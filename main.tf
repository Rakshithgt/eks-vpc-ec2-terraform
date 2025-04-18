provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "vpc" {
  source              = "./vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnets      = var.vpc_public_subnets
  private_subnets     = var.vpc_private_subnets
  availability_zones  = var.vpc_availability_zones
  vpc_name            = var.vpc_name
  nat_gateway_name    = var.nat
  env                 = var.env
  eks_name            = var.eks_name
}


module "eks" {
  source     = "./eks"
  subnet_ids = module.vpc.private_subnet_ids
  eks_name   = var.eks_name
  eks_version = var.eks_version
  env        = var.env
}


module "eks_node_group" {
  source       = "./node_group"
  subnet_ids   = module.vpc.private_subnet_ids
  eks_version  = var.eks_version
  eks_name     = var.eks_name
  env          = var.env
  cluster_name = module.eks.cluster_name
}

module "ec2-instance" {
  source                 = "./ec2-instance"
  ami_id                 = "ami-03f4878755434977f"
  instance_type          = "t2.large"
  key_name               = "mum"
  subnet_id              = module.vpc.public_subnet_ids[0]   # Attach to first public subnet
  vpc_id                 = module.vpc.vpc_id
  tags = {
    Name = "Jenkins-SonarQube"
    Env  = var.env
  }
}
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks_node_group.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
  }

  depends_on = [
    module.eks,
    module.eks_node_group
  ]
}