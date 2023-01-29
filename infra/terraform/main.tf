terraform {
  backend "s3" {
    bucket = "csgods-k8s-state"
    key    = "infra/terraform/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "csgods-k8s"
}
resource "aws_eks_cluster" "eks-cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = "1.24"

  vpc_config {
    subnet_ids = flatten([module.vpc.private_subnets, module.vpc.public_subnets, ])
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}
resource "aws_eks_node_group" "server-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "csgods-node-group"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.large"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 100

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}
resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks-cluster.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
}