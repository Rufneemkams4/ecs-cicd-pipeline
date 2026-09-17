# 1. Default VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
# 2. Finding the existing repository in AWS

data "aws_ecr_repository" "app" {
  name = var.ecr_repository_name
}