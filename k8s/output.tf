# k8s outputs

# kubeconfig
output "kubeconfig" {
  value       = scaleway_k8s_cluster.lunar0.kubeconfig[0]
  description = "Kubeconfig of generate k8s cluster"
  depends_on = [
    scaleway_k8s_cluster.lunar0
  ]
}
