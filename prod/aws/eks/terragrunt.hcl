terraform {
  source = "../../../modules/terraform-aws-eks"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {

  name               = "${local.common_vars.project}-${local.common_vars.environment}-eks" # This will result in a cluster named "companyName-prod-eks"
  kubernetes_version = "1.33"

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_groups = {
    virgosol-prod-eks-worker = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  access_entries = {
    eks_admins = {
      principal_arn     = dependency.eks_admin_role.outputs.arn
    
      policy_associations = {
        admin_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  tags = local.common_vars.tags
}

dependency "vpc" {
  config_path = "../vpc" 
}

dependency "eks_admin_role" {
  config_path = "../iam/roles/eks-admin"
}