provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../"
  
  vpc_cidr = "10.15.0.0/16"
  vpc_name = "Vpc-test"
  private_subnet = ["10.15.10.0/24", "10.15.11.0/24", "10.15.12.0/24"]
  public_subnet = ["10.15.20.0/24", "10.15.21.0/24", "10.15.22.0/24"]
  database_subnet= ["10.15.30.0/24", "10.15.31.0/24", "10.15.32.0/24"]
  default_tags = {"Env" = "teste", "Terraform" = "treu"}
  r53_is_enable = true
  r53_dsn_name  = "rexghost.local"
  
}
