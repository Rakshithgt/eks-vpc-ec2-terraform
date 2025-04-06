resource "aws_vpc" "gtr" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-${var.eks_name}-vpc"
  }
}

resource "aws_internet_gateway" "gtr" {
  vpc_id = aws_vpc.gtr.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.gtr.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                                = "${var.env}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb"                  = 1
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.gtr.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                                = "${var.env}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"                            = 1
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }
}

resource "aws_eip" "nat" {
  count  = 1
  domain = "vpc"
}

resource "aws_nat_gateway" "gtr" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.gtr]

  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gtr.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gtr.id
  }

  tags = {
    Name = "${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.gtr.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gtr.id
  }

  tags = {
    Name = "${var.env}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
