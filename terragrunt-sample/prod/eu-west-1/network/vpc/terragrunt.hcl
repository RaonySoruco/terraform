terraform {
  source = "git::git@github.com:rexrafa/terraform-blueprint.git//network/vpc"
}

include {
  path = find_in_parent_folders()
}

#------------------------------------------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------------------------------------------
inputs = {
  vpc_cidr = "10.15.0.0/16"
  vpc_name = "terragrunt-vpc"
  r53_dns_name = "rexghost.local"
}
