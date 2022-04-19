terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }

    aws = {
      source = "hashicorp/aws"
    }
  }
}




provider "helm" {
  kubernetes {
    host                   = null_resource.kubeconfig.triggers.host
    token                  = null_resource.kubeconfig.triggers.token
    cluster_ca_certificate = base64decode(null_resource.kubeconfig.triggers.cluster_ca_certificate)
  }
}


provider "kubernetes" {
  host                   = null_resource.kubeconfig.triggers.host
  token                  = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(null_resource.kubeconfig.triggers.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = scaleway_k8s_cluster.lunar0.kubeconfig[0].host
  token                  = null_resource.kubeconfig.triggers.token
  cluster_ca_certificate = base64decode(null_resource.kubeconfig.triggers.cluster_ca_certificate)
  load_config_file       = false
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
