
data "aws_ec2_transit_gateway_route_table" "route_table" {
  filter {
    name   = "tag:Name"
    values = [var.transit_gateway_route_table_name]
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = data.aws_ec2_transit_gateway_route_table.route_table.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  tags = merge(
    {
      "Name" = module.vpc.vpc_id,
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.route_table.id
}

resource "aws_route" "gateway_of_last_resort" {
  route_table_id         = module.vpc.private_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway_route_table.route_table.transit_gateway_id
}
