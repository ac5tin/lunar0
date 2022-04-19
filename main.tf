module "k8s" {
  source     = "./k8s"
  zone       = var.zone
  project_id = var.project_id
  # k8s
  k8s_version      = var.k8s_version
  node_type        = var.node_type
  cluster_size     = var.cluster_size
  cluster_min_size = var.cluster_min_size
  cluster_max_size = var.cluster_max_size
  # cert
  cluster_issuer_email = var.cluster_issuer_email
  aws_access_key       = var.aws_access_key
  aws_secret_key       = var.aws_secret_key
  aws_region           = var.aws_region
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
