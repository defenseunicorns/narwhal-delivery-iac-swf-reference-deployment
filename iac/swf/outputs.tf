output "vpc" {
  description = "VPC module output data"
  value       = module.vpc
  sensitive   = true
}

output "eks" {
  description = "EKS module output data"
  value       = module.eks
  sensitive   = true
}

output "bastion" {
  description = "Bastion module output data"
  value       = module.bastion
  sensitive   = true
}

output "zarf" {
  description = "Zarf module output data"
  value       = module.zarf
  sensitive   = true
}
