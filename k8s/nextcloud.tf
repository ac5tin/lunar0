# nextcloud
resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = "nextcloud"
  }
}



resource "helm_release" "nextcloud" {
  depends_on = [
    kubernetes_namespace.nextcloud,
    time_sleep.wait_for_scaleway_csi,
  ]
  name       = "nextcloud"
  namespace  = "nextcloud"
  repository = "https://nextcloud.github.io/helm/"
  chart      = "nextcloud"
  set {
    name  = "image.repository"
    value = "nextcloud"
  }

  set {
    name  = "image.tag"
    value = "23.0.3-apache"
  }

  // nextcloud settings
  set {
    name  = "nextcloud.host"
    value = "nextcloud.downme.xyz"
  }
  set {
    name  = "nextcloud.username"
    value = "admin"
  }
  set {
    name  = "nextcloud.password"
    value = var.nextcloud_password
  }

  set {
    name  = "nextcloud.configs.custom\\.config\\.php"
    value = <<-EOT
<?php
  $CONFIG = array (
    'overwriteprotocol' => 'https'
  );
EOT
  } # database

  # database
  set {
    name  = "postgresql.enabled"
    value = true
  }

  set {
    name  = "postgresql.primary.persistence.enabled"
    value = true
  }
  set {
    name  = "postgresql.primary.persistence.storageClass"
    value = "scw-bssd"
  }

  # data persistence
  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "persistence.storageClass"
    value = "scw-bssd"
  }
  set {
    name  = "persistence.size"
    value = "100Gi"
  }
}



resource "kubernetes_ingress_v1" "nextcloud-ingress" {
  depends_on = [
    kubernetes_namespace.nextcloud,
    helm_release.nextcloud,
  ]
  metadata {
    name      = "nextcloud-ingress"
    namespace = "nextcloud"
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target"  = "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "8G"
    }
  }
  spec {
    tls {
      hosts       = ["nextcloud.downme.xyz"]
      secret_name = "downme-xyz-tls"
    }
    rule {
      host = "nextcloud.downme.xyz"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "nextcloud"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}




resource "aws_route53_record" "nextcloud" {
  name    = "nextcloud.downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}
