# 1. Hanya FRONTEND boleh akses BACKEND
resource "kubernetes_network_policy_v1" "allow_frontend_to_backend" {
  metadata { 
    name      = "allow-frontend-to-backend"
    namespace = kubernetes_namespace_v1.backend_ns.metadata[0].name
    }
  spec {
    pod_selector { 
      match_labels = { app = "backend" } 
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        namespace_selector {
          match_labels = { team = "frontend-team" }
        }
        pod_selector { 
          match_labels = { app  = "frontend" } 
        }
      }
      ports {
        protocol  = "TCP"
        port      = var.backend_container_port
      }
    }
  }
}

# 2. Hanya BACKEND boleh akses DATABASE
resource "kubernetes_network_policy_v1" "allow_backend_to_database" {
  metadata { 
    name      = "allow-backend-to-database" 
    namespace = kubernetes_namespace_v1.database_ns.metadata[0].name
  }
  spec {
    pod_selector { 
      match_labels = { app = "database" } 
      }
    policy_types = ["Ingress"]
    ingress {
      from {
        namespace_selector {
          match_labels = { team = "backend-team" }
        }
        pod_selector { 
          match_labels = { app  = "backend" } 
        }
      }
      ports {
        protocol = "TCP"
        port     = var.database_port
      }
    }
  }
}