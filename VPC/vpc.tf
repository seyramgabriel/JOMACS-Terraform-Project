resource "aws_vpc" "star" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "private_sn1" {
  vpc_id            = aws_vpc.star.id
  cidr_block        = var.subnet1_cidr
  availability_zone = var.az[1]
  tags = {
    Name = var.subnetnames[0]
  }
}

resource "aws_subnet" "public_sn1" {
  vpc_id            = aws_vpc.star.id
  cidr_block        = var.subnet2_cidr
  availability_zone = var.az[0]
  tags = {
    Name = var.subnetnames[1]
  }
}

resource "aws_subnet" "public_sn2" {
  vpc_id            = aws_vpc.star.id
  cidr_block        = var.subnet3_cidr
  availability_zone = var.az[1]
  tags = {
    Name = var.subnetnames[2]
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.star.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.star.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_sn1_association" {
  subnet_id      = aws_subnet.public_sn1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public_sn2_association" {
  subnet_id      = aws_subnet.public_sn2.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private_sn1_association" {
  subnet_id      = aws_subnet.private_sn1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.star.id

  tags = {
    Name = "star-internet-gateway"
  }
}

resource "aws_route" "public-route-table-route-for-igw" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gw.id
}

resource "aws_eip" "eip-for-nat-gw" {
  associate_with_private_ip = var.nat-gw-ip
  tags = {
    Name = "star-eip"
  }
}

resource "aws_nat_gateway" "star-nat-gw" {
  allocation_id = aws_eip.eip-for-nat-gw.id
  subnet_id     = aws_subnet.public_sn1.id

  tags = {
    Name = "star-nat-gw"
  }

  depends_on = [aws_internet_gateway.internet-gw]
}

resource "aws_route" "private-route-table-route-for-nat-gw" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.star-nat-gw.id
}

