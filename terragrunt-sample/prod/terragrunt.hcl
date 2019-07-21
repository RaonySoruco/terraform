remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "terragrunt-prod"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
  }
}

inputs = {
  aws_region                   = "eu-west-1"
  tfstate_global_bucket        = "terragrunt-prod"
  tfstate_global_bucket_region = "eu-west-1"
  enviroment = "Production"
  owner = "Terragrunt"
}