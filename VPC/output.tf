/*output "vpc_cidr_block" {
  value = aws_vpc.star.cidr_block
  sensitive = true
}*/

output "vpc_id" {
  value     = aws_vpc.star.id
  sensitive = true
}

output "public_sn1_id" {
  value     = aws_subnet.public_sn1.id
  sensitive = true
}

output "public_sn2_id" {
  value     = aws_subnet.public_sn2.id
  sensitive = true
}

output "private_sn1_id" {
  value     = aws_subnet.private_sn1.id
  sensitive = true
}

