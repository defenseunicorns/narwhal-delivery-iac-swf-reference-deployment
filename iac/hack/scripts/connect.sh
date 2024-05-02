#!/bin/bash

# this needs a refactor to get the secret from the aws secret manager, also check user's ssh config
# can also fetch the ssh key from the secret manager for the bottlerocket nodes

set -o pipefail

# Function to handle SIGINT (Ctrl+C)
cleanup() {
  echo "Caught SIGINT signal. Running cleanup script..."
  # explicitly kill off sshuttle daemon, otherwise sometimes weird things happen with the sshuttle client on reconnection attempts
  pgrep sshuttle && kill $(pgrep sshuttle) && echo "killed off sshuttle daemon" || echo "sshuttle not running"
  echo "cleanup completed."
  exit 0
}

# Trap SIGINT (Ctrl+C) and call the cleanup function
trap cleanup SIGINT

echo "Starting main script..."
git config --global --add safe.directory /app &&
  cd iac && terraform init &&
  sshuttle -D -e "sshpass -p \"my-password\" ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"aws ssm --region $(terraform output -raw bastion_region) start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p\"" --dns --disable-ipv6 -vr ec2-user@$(terraform output -raw bastion_instance_id) $(terraform output -raw vpc_cidr) &&
  aws eks --region $(terraform output -raw bastion_region) update-kubeconfig --name $(terraform output -raw eks_cluster_name) &&
  echo "SShuttle is running and KUBECONFIG has been set. Try running kubectl get nodes." &&
  bash

# Keep the script running to catch Ctrl+C
while true; do
  echo "Ctrl+C (SIGINT) to exit gracefully"
  sleep 1
done
