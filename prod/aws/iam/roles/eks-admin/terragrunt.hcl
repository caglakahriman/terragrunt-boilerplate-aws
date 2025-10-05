terraform {
  source = "../../../../../modules/terraform-aws-iam//modules/iam-role"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  eks_users   = ["user.name"] # Can extend here to give access
}

inputs = {
  name = "${local.common_vars.project}-${local.common_vars.environment}-eks-admin"
  use_name_prefix = false
  
  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole"
      ]
      principals = [{
        type = "AWS"
        identifiers = [for u in local.eks_users : "arn:aws:iam::${local.common_vars.aws_account_id}:user/${u}"] # Dynamic handling of "eks_users" stated in locals.
      }]
    }
  }

  policies = {
    EKSAdmin = dependency.eks_admin_policy.outputs.id
  }

  tags = local.common_vars.tags
}

dependency "eks_admin_policy" {
  config_path = "../../policies/eks-admin"
}