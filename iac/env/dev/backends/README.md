# Backends

backends files are generted by the iac/bootstrap terraform module
You want to check these in for long lived environments, but not for ephemeral ones.

```bash
export env=dev
export root_module=bootstrap
pushd "iac/${root_module}"

terraform init
terraform validate
terraform plan -var-file ../env/${env}/tfvars/common.terraform.tfvars -var-file ../env/${env}/tfvars/${root_module}.terraform.tfvars
terraform apply -var-file ../env/${env}/tfvars/common.terraform.tfvars -var-file ../env/${env}/tfvars/${root_module}.terraform.tfvars -auto-approve

popd

export root_module=swf
pushd "iac/${root_module}"
terraform init -reconfigure -backend-config=../env/${env}/backends/${root_module}-backend.conf
terraform validate
terraform plan -var-file ../env/${env}/tfvars/common.terraform.tfvars -var-file ../env/${env}/tfvars/${root_module}.terraform.tfvars
terraform apply -var-file ../env/${env}/tfvars/common.terraform.tfvars -var-file ../env/${env}/tfvars/${root_module}.terraform.tfvars -auto-approve
```
