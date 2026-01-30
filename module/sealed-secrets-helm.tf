resource "helm_release" "sealed_secrets" {
  name      = "sealed-secrets"
  namespace = kubernetes_namespace_v1.sealed_secrets.metadata[0].name

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"

  # 🔒 FIXED chart version (matches cluster)
  version = var.chart_version

  values = [
    file(var.values_path)
  ]

  wait    = true
  timeout = 600

  force_update  = true
  recreate_pods = true

  depends_on = [
    kubernetes_namespace_v1.sealed_secrets
  ]
}
