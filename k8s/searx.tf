# searxng
resource "kubernetes_namespace" "searx" {
  metadata {
    name = "searx"
  }
}


resource "kubernetes_deployment" "searxng" {
  depends_on = [
    kubernetes_namespace.searx
  ]
  metadata {
    name      = "searxng"
    namespace = "searx"
  }
  spec {
    selector {
      match_labels = {
        app = "searxng"
      }
    }
    template {
      metadata {
        labels = {
          app = "searxng"
        }
      }
      spec {
        container {
          image = "searxng/searxng:2024.1.19-047c7a7cf"
          name  = "searxng"
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.2"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "searxng" {
  depends_on = [
    kubernetes_deployment.searxng
  ]
  metadata {
    name      = "searxng"
    namespace = "searx"
  }
  spec {
    selector = {
      app = "searxng"
    }
    port {
      port = 8080
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "searx-ingress" {
  depends_on = [
    kubernetes_namespace.searx,
    kubernetes_service.searxng
  ]
  metadata {
    name      = "searx-ingress"
    namespace = "searx"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    tls {
      hosts       = ["searx.downme.xyz"]
      secret_name = "downme-xyz-tls"
    }
    rule {
      host = "searx.downme.xyz"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "searxng"
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



resource "aws_route53_record" "searx" {
  name    = "searx.downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}
