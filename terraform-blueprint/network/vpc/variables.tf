variable "aws_region" {
  default = "AWS region"
}
variable "vpc_cidr" {
  description = "VPC CIDR exemple 10.0.0.0/16"
}
variable "vpc_name" {
  description = "VPC name"
}
variable "r53_dns_name" {
  description = "Domain name like example.com"
}
variable "enviroment" {
  description = "Tag enviroment"
}
variable "owner" {
  description = "Tag owner"
}
