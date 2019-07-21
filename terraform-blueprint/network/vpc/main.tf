provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}

  required_version = ">= 0.12.0"
}


#------------------------------------------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "github.com/rexrafa/terraform-module-vpc"
  
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  private_subnet = [cidrsubnet(var.vpc_cidr, 8, 10), cidrsubnet(var.vpc_cidr, 8, 11), cidrsubnet(var.vpc_cidr, 8, 12)]
  public_subnet = [cidrsubnet(var.vpc_cidr, 8, 20), cidrsubnet(var.vpc_cidr, 8, 21), cidrsubnet(var.vpc_cidr, 8, 22)]
  database_subnet= [cidrsubnet(var.vpc_cidr, 8, 30), cidrsubnet(var.vpc_cidr, 8, 31), cidrsubnet(var.vpc_cidr, 8, 32)]
  default_tags = {"Env" = var.enviroment, "Owner"  = var.owner,"Terraform" = "treu"}
  r53_is_enable = true
  r53_dsn_name  = var.r53_dns_name
}