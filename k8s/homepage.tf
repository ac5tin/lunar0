# homepage
resource "kubernetes_namespace" "homepage" {
  metadata {
    name = "homepage"
  }
}



# deployment
resource "kubernetes_deployment" "homepage" {
  depends_on = [
    kubernetes_namespace.homepage,
  ]
  metadata {
    name      = "homepage"
    namespace = "homepage"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "homepage"
      }
    }
    template {
      metadata {
        labels = {
          app = "homepage"
        }
      }
      spec {
        container {
          name  = "homepage"
          image = "httpd:2.4.53"
          port {
            container_port = 80
          }
          resources {
            requests = {
              cpu    = "0.01"
              memory = "8Mi"
            }
            limits = {
              cpu    = "0.01"
              memory = "16Mi"
            }
          }
        }
      }
    }
  }
}



resource "kubernetes_service" "homepage" {
  depends_on = [
    kubernetes_deployment.homepage
  ]
  metadata {
    name      = "homepage"
    namespace = "homepage"
  }
  spec {
    selector = {
      app = "homepage"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "homepage-ingress" {
  depends_on = [
    kubernetes_namespace.homepage,
    kubernetes_service.homepage
  ]
  metadata {
    name      = "homepage-ingress"
    namespace = "homepage"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    tls {
      hosts       = ["downme.xyz"]
      secret_name = "downme-xyz-tls"
    }
    rule {
      host = "downme.xyz"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "homepage"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}



resource "aws_route53_record" "homepage" {
  name    = "downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}

