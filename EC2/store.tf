data "aws_ssm_parameter" "vpc_id" {
  name = "${local.ssm_path_prefix}/star/id"
}

data "aws_ssm_parameter" "subnets_ids" {
  name = "${local.ssm_path_prefix}/subnets/ids"
}