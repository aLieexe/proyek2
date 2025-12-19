# --- FRONTEND ---
resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name = "frontend"
    labels = { app = "frontend" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        labels = { app = "frontend" }
      }
      spec {
        container {
          image = var.frontend_image
          name  = "frontend"
          port {
            container_port = var.frontend_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    type = "NodePort"
    port {
      port        = var.frontend_port
      target_port = var.frontend_port
    }
    selector = {
      app = "frontend"
    }
  }
}