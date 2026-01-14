module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public endpoint + private access enabled
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  eks_managed_node_groups = {
    ng_ha = {
      name           = "ng-ha"
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"

      min_size     = 3
      desired_size = 3
      max_size     = 6

      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Name = var.cluster_name
  }
}
