# --- DATABASE ---
resource "kubernetes_secret_v1" "database_credentials" {
  metadata {
    name      = "database-credentials"
    namespace = kubernetes_namespace_v1.database_ns.metadata[0].name
  }
  data = {
    username = var.database_username
    password = var.database_password
  }
  type = "Opaque"
}

resource "kubernetes_deployment_v1" "database" {
  metadata {
    name      = "database"
    namespace = kubernetes_namespace_v1.database_ns.metadata[0].name
    labels    = { app = "database" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "database" }
    }
    template {
      metadata {
        namespace = kubernetes_namespace_v1.database_ns.metadata[0].name
        labels    = { app = "database" }
      }
      spec {
        volume {
          name = "database-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.database_pvc.metadata[0].name
          }
        }

        container {
          image = var.database_image
          name  = "database"
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.database_credentials.metadata[0].name
                key  = "password"
              }
            }
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.database_credentials.metadata[0].name
                key  = "username"
              }
            }
          }
          port {
            container_port = var.database_port
          }
          volume_mount {
            name        = "database-storage"
            mount_path  = "/var/lib/postgresql/data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "database" {
  metadata {
    name      = "database"
    namespace = kubernetes_namespace_v1.database_ns.metadata[0].name
  }
  spec {
    type = "ClusterIP"
    port {
      port        = var.database_port
      target_port = var.database_port
    }
    selector = {
      app = "database"
    }
  }
}