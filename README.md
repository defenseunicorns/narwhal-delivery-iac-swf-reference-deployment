# aws-narwhal-iac-swf-reference-deployment

This repository contains the Infrastructure as Code for Deploying UDS SWF on EKS.

At a high level the IaC will deploy the following resources:

1. VPC
   1. Two CIDRs, one CG-NAT for pod ips and one private
2. Bastion instance
3. EKS Cluster
   1. Kubernetes related cloud resources are staged via this module through <https://github.com/aws-ia/terraform-aws-eks-blueprints-addons>, usage of these resources is done through zarf packages that are included in the UDS bundle in this repository.

#### tl;dr: -

```bash
# Deploy AWS EKS cluster + zarf + uds-core + swf
uds run set-env --set ENV=dev
uds run all-up

# Destroy in reverse order
uds run all-down
```

## pre-requisites

1. UDS cli
2. OpenTofu
3. AWS cli
4. Kubectl

## Usage

UDS tasks are used in this project.
run `uds run --list-all` to see available tasks from `./tasks.yaml`

### Tofu/Terraform

Order of root module deployment:

1. iac/bootstrap
2. iac/swf
3. iac/transit-gateway

### Bootstrap

[Bootstrap module](./iac/bootstrap/README.md) - This module is used to create the initial resources required for the rest of the modules to be deployed. It creates the terraform backend and the s3 bucket and dynamodb table required for the backend for the rest of the modules. It also templates out a `backend.tf` file and a `$root-module-backend.tfconfig` file that are used to configure terraform to utilize an s3 backend. Each environment (dev, staging, prod) has its own backend-config file that is used to configure the backend. This is called a [partial backend configuration](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#partial-configuration).

#### SWF

[SWF module](./iac/swf/README.md) - This module is used to create the resources required for UDS SWF and UDS core. It creates the VPC, EKS cluster, node groups, bastion instance, etc. It also creates the necessary IAM roles and policies required for the EKS cluster and In-cluster UDS SWF applications.

#### Transit Gateway

[Transit Gateway module](./iac/transit-gateway/README.md) - This module is used to create the resources required for environments using an existing transit gateway or creating a new transit gateway. It creates the transit gateway, transit gateway route table, transit gateway route, transit gateway attachment, and transit gateway route table associations required for ingress and egress traffic.
