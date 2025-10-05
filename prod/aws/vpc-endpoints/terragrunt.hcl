# Specify which module to use

terraform {
  source = "../../../modules/terraform-aws-vpc//modules/vpc-endpoints"
}

# Terragrunt's backend configuration file

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Local variables to use within this .hcl file

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

# Inputs to the specified module. This part will change based on the module used
inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  create_security_group = true
  security_group_rules = {
    https_within_vpc = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]
    }
  }

  endpoints = {
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
    }
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
    }
    sts = {
      service             = "sts"
      private_dns_enabled = true
    }
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
    }
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
    }
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
    }

    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = dependency.vpc.outputs.private_route_table_ids
    }
  }
  tags = local.common_vars.tags
}

# Depedency block to indicate this resource should not be created before the below "vpc" resource

dependency "vpc" {
  config_path = "../vpc"
}
