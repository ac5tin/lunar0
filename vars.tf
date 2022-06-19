variable "project_id" {
  type        = string
  description = "Project ID"
}


variable "region" {
  type        = string                         // value type
  description = "Values: fr-par nl-ams pl-waw" // documentation
}


variable "zone" {
  type        = string                                                 // value type
  description = "Values: fr-par-1 fr-par-2 fr-par-3 nl-ams-1 pl-waw-1" // documentation
}

variable "scw_access_key" {
  type        = string
  description = "SCW access key"
}

variable "scw_secret_key" {
  type        = string
  description = "SCW secret key"
}




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


variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "nextcloud_password" {
  type        = string
  description = "Nextcloud password"
}

