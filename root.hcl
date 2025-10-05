# The root.hcl is where we setup backend configuration for the project.

# In this example, the terraform state files are kept in a S3 bucket called "project-terraform-states".

# L13 contains configuration to ensure "state-locking" which prevents multiple people altering the same state at the same time.
# The DynamoDB table must be created in advance.

# "profile" must be present in your local .aws configuration.
# Don't forget to adjust the "region" based on your needs.

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "project-terraform-states"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-locks"
    profile        = "aws-config-profile-name"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "eu-north-1"
  profile = "aws-config-profile-name"
}
EOF
}

inputs = {
  aws_region = "eu-north-1"
}