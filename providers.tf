terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}


provider "scaleway" {
  access_key = var.scw_access_key
  secret_key = var.scw_secret_key
  project_id = var.project_id
  zone       = var.zone
  region     = var.region
}
