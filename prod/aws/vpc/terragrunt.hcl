terraform {
  source = "../../../modules/terraform-aws-vpc"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {

  name = "${local.common_vars.project}-${local.common_vars.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  database_subnets = ["10.0.30.0/24", "10.0.31.0/24", "10.0.32.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${local.common_vars.project}-${local.common_vars.environment}-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${local.common_vars.project}-${local.common_vars.environment}-eks" = "shared"
  }

  vpc_tags = local.common_vars.tags
}
