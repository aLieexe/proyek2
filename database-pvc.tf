# --- DATABASE PERSISTENT STORAGE ---
resource "kubernetes_persistent_volume_claim_v1" "database_pvc" {
  metadata {
    name      = "database-pvc"
    namespace = kubernetes_namespace_v1.database_ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}