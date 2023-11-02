locals {
  #ssm_path_prefix = "/seyram/us-east-2/vpc"
  ssm_path_prefix = format("/%s/%s/%s", "seyram", "us-east-2", "vpc")
}