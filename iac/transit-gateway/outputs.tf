# output "vpc_debug" {
#   value = data.terraform_remote_state.swf_state.outputs.vpc
# }

output "vpc_name" {
  value = data.terraform_remote_state.swf_state.outputs.vpc.name
}

output "route_config_map" {
  value = module.transit_gateway_attachment.route_config_map
}

output "transit_gateway_attachment" {
  value = module.transit_gateway_attachment
}
