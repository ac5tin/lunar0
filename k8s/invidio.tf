# invidio
resource "kubernetes_namespace" "invidio" {
  metadata {
    name = "invidio"
  }
}


# db
resource "kubernetes_persistent_volume_claim" "invidio-data" {
  depends_on = [
    kubernetes_namespace.invidio,
  ]
  metadata {
    name      = "invidio-data"
    namespace = "invidio"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "scw-bssd"
  }
}


resource "kubernetes_deployment" "invidio_postgres" {
  depends_on = [
    kubernetes_namespace.invidio,
    kubernetes_persistent_volume_claim.invidio-data,
  ]
  metadata {
    name      = "postgres"
    namespace = "invidio"
  }


  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:14"
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value = "invidio"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "invidio"
          }
          env {
            name  = "POSTGRES_DB"
            value = "invidio"
          }
          volume_mount {
            name       = "invidio-vol"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "invidio"
          }
        }
        volume {
          name = "invidio-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.invidio-data.metadata.0.name
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "invidio_postgres" {
  depends_on = [
    kubernetes_deployment.invidio_postgres
  ]
  metadata {
    name      = "invidio-pg"
    namespace = "invidio"
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port = 5432
    }
    type = "ClusterIP"
  }
}



# deployment
resource "kubernetes_deployment" "invidio" {
  depends_on = [
    kubernetes_namespace.invidio,
    kubernetes_persistent_volume_claim.invidio-data,
    kubernetes_deployment.invidio_postgres,
    kubernetes_service.invidio_postgres,
  ]
  metadata {
    name      = "invidio"
    namespace = "invidio"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "invidio"
      }
    }
    template {
      metadata {
        labels = {
          app = "invidio"
        }
      }
      spec {
        container {
          name  = "invidio"
          image = "quay.io/invidious/invidious:6ff3a633f7f7c71f5fb4ea821ae6fd85b645e1d5"
          port {
            container_port = 3000
          }
          env {
            name  = "INVIDIOUS_CONFIG"
            value = <<EOF
              db:
                host: invidio-pg
                port: 5432
                user: invidio
                password: invidio
                dbname: invidio
              check_tables: true
            EOF
          }
          resources {
            requests = {
              cpu    = "0.2"
              memory = "128Mi"
            }
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}




resource "kubernetes_service" "invidio" {
  depends_on = [
    kubernetes_deployment.invidio
  ]
  metadata {
    name      = "invidio"
    namespace = "invidio"
  }
  spec {
    selector = {
      app = "invidio"
    }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "invidio-ingress" {
  depends_on = [
    kubernetes_namespace.invidio,
    kubernetes_service.invidio
  ]
  metadata {
    name      = "invidio-ingress"
    namespace = "invidio"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    tls {
      hosts       = ["invidio.downme.xyz"]
      secret_name = "downme-xyz-tls"
    }
    rule {
      host = "invidio.downme.xyz"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "invidio"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}



resource "aws_route53_record" "invidio" {
  name    = "invidio.downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}
