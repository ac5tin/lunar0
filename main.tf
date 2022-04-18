module "k8s" {
  source           = "./k8s"
  zone             = var.zone
  project_id       = var.project_id
  k8s_version      = var.k8s_version
  node_type        = var.node_type
  cluster_size     = var.cluster_size
  cluster_min_size = var.cluster_min_size
  cluster_max_size = var.cluster_max_size
  providers = {
    scaleway = scaleway
  }
}

# outputs
output "k8s_kubeconfig" {
  value       = module.k8s.kubeconfig
  description = "Kubeconfig of generate k8s cluster"
  depends_on = [
    module.k8s
  ]
}
