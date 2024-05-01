# Steps to get logdog logs out of bottlerocket node

<https://github.com/bottlerocket-os/bottlerocket/blob/41d9aa58314746fad42c2fe223b94618101be38c/README.md?plain=1#L462-L481>

Useful terminology and tools:

<https://github.com/bottlerocket-os/bottlerocket/blob/6cfc06439213e89adf1f5a8552cb10c42a7ffbd3/GLOSSARY.md>

## SSH Config

You need to be able to ssh into the node either directly or through AWS SSM session manager.

### Configure your local machine's SSH config

Modify local .ssh config:
host i-*mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"

or

host i-*mi-*
    ProxyCommand sh -c "aws-vault exec $yourawsvaultprofilenamehere -- aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"

## Bootstrapping bottlerocket nodes to allow SSH access as ec2 user

### Create Amazon ec2 keypair

Either do it through the terraform or do it through the ec2 console
<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html>

> [!TIP]
> There's a module for that: <https://github.com/terraform-aws-modules/terraform-aws-key-pair>.

You can attach the keypair to the bottlerocket node groups through the Launch Template for each node group or set defaults.
<https://github.com/terraform-aws-modules/terraform-aws-eks/blob/84effa0e30f64ba2fceb7f89c2a822e92f1ee1ea/node_groups.tf#L496>
<https://github.com/terraform-aws-modules/terraform-aws-eks/blob/84effa0e30f64ba2fceb7f89c2a822e92f1ee1ea/modules/self-managed-node-group/variables.tf#L283-L287>

When the bottlerocket nodes come up, they will automagically set that keypair into the ec2-user's authorized_keys file.

Then you can do something like:

```bash
aws secretsmanager get-secret-value --secret-id "$id" --query 'SecretString' --output text > ~/.ssh/du-uds-swf.key

ssh -i ~/.ssh/du-uds-swf.key ec2-user@$instance_id "sudo sheltie logdog"

ssh -i ~/.ssh/du-uds-swf.key ec2-user@$instance_id "cat /.bottlerocket/support/bottlerocket-logs.tar.gz" > bottlerocket-logs.tar.gz
```

### Create your own keypair (dirty oneoff && hacky solution)

- Add an SSH key to the nodes - through the bottlerocket's userdata. Here's a with an example on how to override the admin container's userdata <https://github.com/bottlerocket-os/bottlerocket/discussions/1573#discussioncomment-740854>
  - This modifies the admin container and lets you SSH into the bottlerocket node as ec2-user. - something to do with this code - <https://github.com/bottlerocket-os/bottlerocket/blob/41d9aa58314746fad42c2fe223b94618101be38c/sources/api/shibaken/src/admin_userdata.rs#L51-L74>

## Run Logdog and get logs out of the bottlerocket node through SSM

```bash
aws ssm start-session --target i-$instance_id
```

as ssm-user run the following commands:

- `enter-admin-container`
- `sudo sheltie`
- `logdog`

from your local machine, with your .ssh config and key already configured; copy the tarballed logs out

```bash
ssh -i ${HOME}/.ssh/$yourkeyhere ec2-user@$instance_id "cat /.bottlerocket/support/bottlerocket-logs.tar.gz" > bottlerocket-logs.tar.gz
```
