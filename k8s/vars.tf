# k8s base
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


# cert
variable "cluster_issuer_email" {
  type        = string
  description = "Email of the cluster issuer"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}



# global
variable "zone" {}
variable "project_id" {}
