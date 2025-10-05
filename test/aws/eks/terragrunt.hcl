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

  name               = "${local.common_vars.project}-${local.common_vars.environment}-eks" # This will result in a cluster named "companyName-test-eks"
  #...
}