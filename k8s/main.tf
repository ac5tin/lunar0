resource "scaleway_k8s_cluster" "lunar0" {
  name    = "lunar0"
  version = var.k8s_version
  cni     = "calico"

  autoscaler_config {
    disable_scale_down         = false
    scale_down_delay_after_add = "5m"
    estimator                  = "binpacking"
  }
}


// https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_pool
// to import pool:
// terraform import scaleway_k8s_pool.mypool fr-par/11111111-1111-1111-1111-111111111111

resource "scaleway_k8s_pool" "dust-0" {
  cluster_id  = scaleway_k8s_cluster.lunar0.id
  name        = "dust-0"
  node_type   = var.node_type
  size        = var.cluster_size
  min_size    = var.cluster_min_size
  max_size    = var.cluster_max_size
  autoscaling = true
  autohealing = true
}


/*
The null_resource is needed because when the cluster is created,
it's status is pool_required, but the kubeconfig can already be downloaded.
It leads the kubernetes provider to start creating its objects,
but the DNS entry for the Kubernetes master is not yet ready,
that's why it's needed to wait for at least a pool.
[source](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_cluster)
*/
resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.dust-0] # at least 1 pool here
  triggers = {
    host                   = scaleway_k8s_cluster.lunar0.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.lunar0.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.lunar0.kubeconfig[0].cluster_ca_certificate
  }
}


