provider "aws" {
  region = var.region
  # default_tags {
  #   tags = var.tags #bug https://github.com/hashicorp/terraform-provider-aws/issues/19583#issuecomment-855773246
  # }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/sh"
    args        = ["-c", "for i in $(seq 1 30); do curl -s -k -f ${module.eks.cluster_endpoint}/healthz > /dev/null && break || sleep 10; done && aws eks --region ${var.region} get-token --cluster-name ${local.cluster_name}"]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "/bin/sh"
      args        = ["-c", "for i in $(seq 1 30); do curl -s -k -f ${module.eks.cluster_endpoint}/healthz > /dev/null && break || sleep 10; done && aws eks --region ${var.region} get-token --cluster-name ${local.cluster_name}"]
    }
  }
}
