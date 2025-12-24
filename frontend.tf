# --- FRONTEND ---
resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace_v1.frontend_ns.metadata[0].name
    labels    = { app = "frontend" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        namespace = kubernetes_namespace_v1.frontend_ns.metadata[0].name
        labels    = { app = "frontend" }
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
    namespace = kubernetes_namespace_v1.frontend_ns.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = var.frontend_port
      target_port = var.frontend_port
    }
    selector = {
      app = "frontend"
    }
  }
}