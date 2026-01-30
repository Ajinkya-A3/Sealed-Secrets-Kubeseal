resource "kubernetes_namespace_v1" "sealed_secrets" {
  metadata {
    name = var.namespace
  }
}
