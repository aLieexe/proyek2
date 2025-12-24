# --- BACKEND ---
resource "kubernetes_deployment_v1" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace_v1.backend_ns.metadata[0].name
    labels    = { app = "backend" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "backend" }
    }
    template {
      metadata {
        namespace = kubernetes_namespace_v1.backend_ns.metadata[0].name
        labels    = { app = "backend" }
      }
      spec {
        container {
          image = var.backend_image
          name  = "backend"
          port {
            container_port = var.backend_container_port
          }

          # Database connection
          env {
            name  = "DB_HOST"
            value = var.database_host
          }

          env {
            name  = "DB_PORT"
            value = tostring(var.database_port)
          }

          env {
            name  = "DB_USER"
            value = var.database_username
          }

          env {
            name  = "DB_PASSWORD"
            value = var.database_password
          }

          env {
            name  = "DB_NAME"
            value = var.database_name
          }

          # Backend server port
          env {
            name  = "SERVER_PORT"
            value = tostring(var.backend_container_port)
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace_v1.backend_ns.metadata[0].name
  }
  spec {
    type = "ClusterIP"
    port {
      port        = var.backend_port
      target_port = var.backend_container_port
    }
    selector = {
      app = "backend"
    }
  }
}
