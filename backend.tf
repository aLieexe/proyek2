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