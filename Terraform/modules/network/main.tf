resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "ivolve-vpc"
  }
}
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub1"
  }


}
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub2"
  }


}
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "private-sub1"
  }
}
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "private-sub2"
  }


}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ivolve-igw"
  }

}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route"
  }

}
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id


}
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id


}
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "ivolve-eip"
  }

}
resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    Name = "ivolve-nat"

  }
  depends_on = [aws_internet_gateway.igw]

}
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mynat.id
  }
  tags = {
    Name = "private-route"
  }

}
resource "aws_route_table_association" "private_rt1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private-rt.id

}
resource "aws_route_table_association" "private_rt2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private-rt.id

}
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ivolve-nacl"
  }

}
resource "aws_network_acl_rule" "inbound" {
  network_acl_id = aws_network_acl.nacl.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  egress         = false



}
resource "aws_network_acl_rule" "outbound" {
  network_acl_id = aws_network_acl.nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
resource "aws_network_acl_association" "public_1" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.public_subnet1.id
}

resource "aws_network_acl_association" "public_2" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.public_subnet2.id
}

resource "aws_network_acl_association" "private_1" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.private_subnet1.id
}

resource "aws_network_acl_association" "private_2" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.private_subnet2.id
}