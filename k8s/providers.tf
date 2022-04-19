terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
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
