resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required==true?1:0
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = var.accepter_id==""?data.aws_vpc.default_vpc.id:var.accepter_id
  auto_accept   = var.accepter_id==""?true:false

  tags = merge(var.peering_tags,local.tag)
}

resource "aws_route" "requester_pb" {
  count = var.is_peering_required==true?1:0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = var.accepter_id==""?data.aws_vpc.default_vpc.cidr_block:var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
  
}

resource "aws_route" "requester_pv" {
  count = var.is_peering_required==true?1:0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = var.accepter_id==""?data.aws_vpc.default_vpc.cidr_block:var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}


resource "aws_route" "requester_db" {
  count = var.is_peering_required==true?1:0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = var.accepter_id==""?data.aws_vpc.default_vpc.cidr_block:var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "default_vpc_route" {
  count = var.is_peering_required==true && var.accepter_id==""?1:0
  route_table_id            = data.aws_vpc.default_vpc.main_route_table_id
  destination_cidr_block    = var.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
