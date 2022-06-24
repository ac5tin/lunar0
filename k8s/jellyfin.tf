# Jellyfin
resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = "jellyfin"
  }
}




resource "helm_release" "jellyfin" {
  depends_on = [
    kubernetes_namespace.jellyfin,
    time_sleep.wait_for_scaleway_csi,
  ]
  name       = "jellyfin"
  namespace  = "jellyfin"
  repository = "https://k8s-at-home.com/charts"
  chart      = "jellyfin"
  set {
    name  = "image.repository"
    value = "jellyfin/jellyfin"
  }

  set {
    name  = "image.tag"
    value = "10.8.0"
  }

  # ingress
  set {
    name  = "ingress.main.enabled"
    value = true
  }

  set {
    name  = "ingress.main.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "ingress.main.annotations.nginx\\.ingress\\.kubernetes\\.io/rewrite-target"
    value = "/"
  }

  set {
    name  = "ingress.main.hosts[0].host"
    value = "jellyfin.downme.xyz"
  }


  set {
    name  = "ingress.main.hosts[0].paths[0].path"
    value = "/"
  }


  set {
    name  = "ingress.main.hosts[0].paths[0].pathType"
    value = "Prefix"
  }



  set {
    name  = "ingress.main.hosts[0].paths[0].pathType"
    value = "Prefix"
  }


  set {
    name  = "ingress.main.tls[0].hosts[0]"
    value = "jellyfin.downme.xyz"
  }

  # persistence
  # - config
  set {
    name  = "persistence.config.enabled"
    value = true
  }

  set {
    name  = "persistence.config.storageClass"
    value = "scw-bssd"
  }

  set {
    name  = "persistence.config.accessMode"
    value = "ReadWriteOnce"
  }

  set {
    name  = "persistence.config.size"
    value = "4Gi"
  }

  # - cache
  set {
    name  = "persistence.cache.enabled"
    value = true
  }

  set {
    name  = "persistence.cache.storageClass"
    value = "scw-bssd"
  }

  set {
    name  = "persistence.cache.accessMode"
    value = "ReadWriteOnce"
  }

  set {
    name  = "persistence.cache.size"
    value = "4Gi"
  }

  // - media
  set {
    name  = "persistence.media.enabled"
    value = true
  }

  set {
    name  = "persistence.media.storageClass"
    value = "scw-bssd"
  }

  set {
    name  = "persistence.media.accessMode"
    value = "ReadWriteOnce"
  }

  set {
    name  = "persistence.media.size"
    value = "100Gi"
  }

  # resources
  set {
    name  = "resources.requests.cpu"
    value = "256m"
  }

  set {
    name  = "resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "256m"
  }

  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }

}



resource "aws_route53_record" "jellyfin" {
  name    = "jellyfin.downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}
