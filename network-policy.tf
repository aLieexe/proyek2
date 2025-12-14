# 1. Hanya FRONTEND boleh akses BACKEND
resource "kubernetes_network_policy" "allow_frontend_to_backend" {
  metadata { name = "allow-frontend-to-backend" }
  spec {
    pod_selector { match_labels = { app = "backend" } }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector { match_labels = { app = "frontend" } }
      }
    }
  }
}

# 2. Hanya BACKEND boleh akses DATABASE
resource "kubernetes_network_policy" "allow_backend_to_database" {
  metadata { name = "allow-backend-to-database" }
  spec {
    pod_selector { match_labels = { app = "database" } }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector { match_labels = { app = "backend" } }
      }
    }
  }
}