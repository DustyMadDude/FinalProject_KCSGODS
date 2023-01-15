provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  cluster_name = "csgods-k8s"
}

provider "kubernetes" {

  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks-kubeconfig" {
  source  = "hyperbadger/eks-kubeconfig/aws"
  version = "2.0.0"

  depends_on   = [module.eks]
  cluster_name = local.cluster_name
}

resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig_${local.cluster_name}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    disk_size              = 50
    disk_type              = "gp3"
    disk_throughput        = 150
    disk_iops              = 3000
    capacity_type          = "SPOT"
    eni_delete             = true
    ebs_optimized          = true
    mi_type                = "AL2_x86_64"
    create_launch_template = true
    enable_monitoring      = true
    update_default_version = false
  }
  eks_managed_node_groups = {
    server-1 = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      instance_type = ["t3.large", "t3a.large"]
      capacity_type = "ON_DEMAND"
    }
  }
}