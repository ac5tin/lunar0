# thelounge
resource "kubernetes_namespace" "thelounge" {
  metadata {
    name = "thelounge"
  }
}



resource "helm_release" "thelounge" {
  depends_on = [
    kubernetes_namespace.thelounge,
    time_sleep.wait_for_scaleway_csi,
  ]
  name       = "thelounge"
  namespace  = "thelounge"
  repository = "https://k8s-at-home.com/charts"
  chart      = "thelounge"
  set {
    name  = "image.repository"
    value = "thelounge/thelounge"
  }

  set {
    name  = "image.tag"
    value = "4.2.0-alpine"
  }

  set {
    name  = "ingress.main.enabled"
    value = true
  }

  set {
    name = "ingress.main.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "ingress.main.annotations.nginx\\.ingress\\.kubernetes\\.io/rewrite-target"
    value = "/"
  }

  set {
    name = "ingress.main.hosts[0].host"
    value = "thelounge.downme.xyz"
  }


  set {
    name = "ingress.main.hosts[0].paths[0].path"
    value = "/"
  }


  set {
    name = "ingress.main.hosts[0].paths[0].pathType"
    value = "Prefix"
  }



  set {
    name = "ingress.main.hosts[0].paths[0].pathType"
    value = "Prefix"
  }


  set {
    name = "ingress.main.tls[0].hosts[0]"
    value = "thelounge.downme.xyz"
  }

  set {
    name = "persistence.config.enabled"
    value = true
  }

  set {
    name = "persistence.config.storageClass"
    value = "scw-bssd"
  }

  set {
    name = "persistence.config.accessMode"
    value = "ReadWriteOnce"
  }

  set {
    name = "persistence.config.size"
    value = "4Gi"
  }


}



resource "aws_route53_record" "thelounge" {
  name    = "thelounge.downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}
