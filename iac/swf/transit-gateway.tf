# TODO - Verify this is what is desired
# module "transit_gateway_attach_vpc_and_route" {
#   source = "git::https://github.com/defenseunicorns/terraform-aws-transit-gateway.git?ref=feature/setup-transit-gateway-and-example"
#   vpc_id                          = module.vpc.vpc_id
#   subnet_ids                      = module.vpc.private_subnets
#   tags                            = local.tags
#   vpc_route_table_id              = module.vpc.vpc_main_route_table_id
#   target_transit_gateway_tag_name = var.target_transit_gateway_tag_name
#   peered_transit_gateway_tag_name = var.peered_transit_gateway_tag_name
# }
