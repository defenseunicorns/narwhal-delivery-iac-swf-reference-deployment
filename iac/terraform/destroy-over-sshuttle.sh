#!/bin/bash

set -o pipefail

git config --global --add safe.directory /app \
		&& cd iac \
    && ([ ! -f terraform.tfstate ] && terraform init || true) \
		&& sshuttle -D -e "sshpass -p \"my-password\" ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"aws ssm --region $(terraform output -raw bastion_region) start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p\"" --dns --disable-ipv6 -vr ec2-user@$(terraform output -raw bastion_instance_id) $(terraform output -raw vpc_cidr) \
		&& terraform init \
    && terraform destroy -auto-approve -var-file="tfvars/dev/s.tfvars" -target="module.eks" \
    && pgrep sshuttle && kill $(pgrep sshuttle) && echo "killed off sshuttle daemon" || echo "sshuttle not running" \
    && exit 0
