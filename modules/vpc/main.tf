resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${var.name}-vpc" }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-igw" }
  )
}

# Public Subnets (for Bastion, NAT, etc.)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]

  tags = merge(
    var.tags,
    { Name = "${var.name}-public-${count.index + 1}" }
  )
}

# Private Subnets (for RDS, app servers)
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  # explicit intent: private subnets should NOT assign public IPs
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    { Name = "${var.name}-private-${count.index + 1}" }
  )
}

# EIP(s) and NAT Gateway(s) — one per public subnet/AZ for HA
resource "aws_eip" "nat" {
  count = length(var.public_subnets)
  # provider allocates VPC scoped EIP by default; no vpc = true needed
  tags = merge(
    var.tags,
    { Name = "${var.name}-nat-eip-${count.index + 1}" }
  )
}

resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  # ensure IGW exists first
  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    { Name = "${var.name}-nat-${count.index + 1}" }
  )
}

# Public Route Table -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-public-rt" }
  )
}

resource "aws_route_table_association" "public_assoc" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (one per private subnet) -> NAT in same index/AZ
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-private-rt-${count.index + 1}" }
  )
}

resource "aws_route_table_association" "private_assoc" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

