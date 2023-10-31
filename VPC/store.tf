resource "aws_ssm_parameter" "vpc_id" {
  #name  = "/jomacs/us-west-2/vpc/day4VPC/id"
  name  = "${local.ssm_path_prefix}/star/id"
  type  = "String"
  value = aws_vpc.star.id
}

resource "aws_ssm_parameter" "subnets_ids" {
  #name  = "/jomacs/us-west-2/vpc/pri-subnets/ids"
  name  = "${local.ssm_path_prefix}/subnets/ids"
  type  = "String"
  value = join(",", [aws_subnet.public_sn1.id, aws_subnet.public_sn2.id, aws_subnet.private_sn1.id])
}

/*resource "aws_ssm_parameter" "pub-subnets_ids" {
name  = "/jomacs/us-west-2/vpc/pub-subnets/ids"
 name  = "pub-subnets/ids"
type  = "String"
 value = join(",", [aws_subnet.pub-sn1.id, aws_subnet.pub-sn2.id])
}*/