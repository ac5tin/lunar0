# cert-manager

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# helm install cert-manager
resource "helm_release" "cert-manager" {
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.10.1"
  set {
    name  = "installCRDs"
    value = true
  }
}


resource "time_sleep" "wait_for_cert-manager" {
  depends_on = [
    helm_release.cert-manager
  ]
  create_duration = "10s"
}

resource "kubernetes_secret" "route53-creds" {
  metadata {
    name      = "route53-creds"
    namespace = "cert-manager"
  }
  data = {
    "secret-access-key" = var.aws_secret_key
  }
  type = "Opaque"
}

# cluster issuer
resource "kubectl_manifest" "letsencrypt-prod" {
  depends_on = [
    time_sleep.wait_for_cert-manager
  ]
  # yaml
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${var.cluster_issuer_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - selector: {}
      dns01:
        route53:
          region: us-east-1
          accessKeyID: ${var.aws_access_key}
          secretAccessKeySecretRef:
            name: route53-creds
            key: secret-access-key
  YAML
}

resource "time_sleep" "wait_for_clusterissuer" {

  depends_on = [
    kubectl_manifest.letsencrypt-prod
  ]

  create_duration = "30s"
}


resource "kubernetes_namespace" "networking" {
  metadata {
    name = "networking"
  }
}



resource "kubectl_manifest" "downme-cert" {
  depends_on = [
    time_sleep.wait_for_clusterissuer,
    kubernetes_namespace.networking
  ]
  # yaml
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: "downme-xyz"
  namespace: networking
spec:
  secretName: "downme-xyz-tls"
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: "downme.xyz"
  dnsNames:
  - "downme.xyz"
  - "*.downme.xyz"
  YAML
}
