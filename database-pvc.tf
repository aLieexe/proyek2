# --- DATABASE PERSISTENT STORAGE ---
resource "kubernetes_persistent_volume_claim_v1" "database_pvc" {
  metadata {
    name = "database-pvc"
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