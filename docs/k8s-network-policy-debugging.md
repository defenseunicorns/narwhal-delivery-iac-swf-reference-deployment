# aws-vpc-cni network policy debugging

Debugging network policies with EKS and vpc-cni can be a bit tricky. This guide will help you understand how to debug network policies in your EKS cluster using vpc-cni.

Configure vpc-cni to enable network policy enforcement policy event logs via the `enableNetworkPolicy` and `nodeAgent.enablePolicyEventLogs` configuration values. Optionally log policy events to CloudWatch Logs by setting `nodeAgent.enableCloudWatchLogs` to `true`.

```hcl
cluster_addons = {
  vpc-cni = {
    most_recent          = true
    before_compute       = true
    configuration_values = <<-JSON
      {
        "env": {
          "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
          "ENABLE_PREFIX_DELEGATION": "true",
          "ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
          "WARM_PREFIX_TARGET": "1",
          "ANNOTATE_POD_IP": "true",
          "POD_SECURITY_GROUP_ENFORCING_MODE": "standard"
        },
        "enableNetworkPolicy": "true",
        "nodeAgent": {
          "enablePolicyEventLogs": "true",
          "enableCloudWatchLogs": "false"
        }
      }
    JSON
  }
}
```

> [!TIP]
> `/var/run/aws-routed-eni/network-policy-agent.log` is the default location where network policy agent logs are stored by default. See <https://github.com/aws/aws-network-policy-agent#enable-cloudwatch-logs> for more information.
>

## view network policy agent logs

### On the bottleroocket node

1. Access the node via ssh or via AWS SSM session manager.
2. run:
   1. `enter-admin-container`
   2. `sudo sheltie`
3. Once you see a bash prompt, you can see the network policy logs under `/var/run/aws-routed-eni/network-policy-agent.log`

### Cloudwatch logs

These log streams will be available in Cloudwatch under the log group `/aws/eks/$cluster_name/cluster` prefixed with `aws-network-policy-agent-audit-`.
