terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
  }
}
