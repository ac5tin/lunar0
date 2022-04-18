# k8s


variable "k8s_version" {
  type        = string
  description = "K8s version"
}

variable "node_type" {
  type        = string
  description = "Type of the node"
}

variable "cluster_size" {
  type        = number
  description = "Size of the cluster"
}

variable "cluster_min_size" {
  type        = number
  description = "Minimum size of the cluster"
}


variable "cluster_max_size" {
  type        = number
  description = "Maximum size of the cluster"
}



# pass in from parent
variable "zone" {}
variable "project_id" {}
