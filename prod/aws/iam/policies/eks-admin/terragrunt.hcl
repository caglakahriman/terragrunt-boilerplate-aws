terraform {
  source = "../../../../../modules/terraform-aws-iam//modules/iam-policy"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
    name = "${local.common_vars.project}-${local.common_vars.environment}-eks-admin"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect   = "Allow"
            Action   = [
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:ListNodegroups",
                "eks:DescribeNodegroup",
                "eks:AccessKubernetesApi"
            ]
            Resource = "arn:aws:eks:eu-north-1:${local.common_vars.aws_account_id}:cluster/cluster-env-*"
        }
        ]
    })

    tags = local.common_vars.tags
}
