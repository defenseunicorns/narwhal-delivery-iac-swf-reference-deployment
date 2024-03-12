# Hacks

## DNS Script

For OIDC to work between cluster services they need to be able to resolve each other via their externally facing domain names. For
the reference deployment this is *.uds.dev which globally resolves to `127.0.0.1`. In the cluster we need to rewrite these dns queries
to the load balancer that each service is on.

The dns.sh script patches the CoreDNS config file to have regex based dns query rewrites so that cluster services are able to reach
each other.
