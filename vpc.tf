## VPC ##
resource "aws_vpc" "main" {
  cidr_block = var.cidr
  enable_dns_hostnames = var.dns_hostnames
  tags = merge(var.vpn_tags,local.tag)
}

## Internet Gateway ##
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.igw_tags,local.tag)
}

## Public Subnet ##
resource "aws_subnet" "public" {
  count = length(var.pb_cidrs)
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]
  cidr_block = var.pb_cidrs[count.index]

  tags = merge(var.common_tags, {
    Name="public-${local.az_names[count.index]}"
  })
}

## Private Subnet ##
resource "aws_subnet" "private" {
  count = length(var.pv_cidrs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block = var.pv_cidrs[count.index]

  tags = merge(var.common_tags, {
    Name="private-${local.az_names[count.index]}"
  })
}

## Database Subnet ##
resource "aws_subnet" "database" {
  count = length(var.db_cidrs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block = var.db_cidrs[count.index]

  tags = merge(var.common_tags, {
    Name="db-${local.az_names[count.index]}"
  })
}

## DB subnet group##
resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-${var.env}"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(var.db_subnet_grp_tags,local.tag)
}

## Elastic IP ##
resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = merge(var.eip_tags,local.tag)

}

## NAT Gateway ##
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.nat_tags,local.tag)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

## Public Route Table ##
resource "aws_route_table" "public" {
  vpc_id     = aws_vpc.main.id
  tags = { Name= "public-${var.project}-${var.env}"}
}

## Private Route Table ##
resource "aws_route_table" "private" {
  vpc_id     = aws_vpc.main.id
  tags = {  Name= "private-${var.project}-${var.env}"}
}

## Database Route Table ##
resource "aws_route_table" "database" {
  vpc_id     = aws_vpc.main.id
  tags = {  Name= "database-${var.project}-${var.env}"}
}

## Public Route ##
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

## Private Route ##
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

## Database Route ##
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

## Public subnet association with public route table ##
resource "aws_route_table_association" "public" {
  count = length(var.pb_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

## Private subnet association with private route table ##
resource "aws_route_table_association" "private" {
  count = length(var.pv_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

## database subnet association with database route table ##
resource "aws_route_table_association" "database" {
  count = length(var.db_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}