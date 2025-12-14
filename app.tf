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
          image = "nginx:alpine"
          name  = "frontend"
          port {
            container_port = 80
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
    type = "NodePort" # Cocok untuk Minikube
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "frontend"
    }
  }
}

# --- BACKEND ---
resource "kubernetes_deployment_v1" "backend" {
  metadata {
    name = "backend"
    labels = { app = "backend" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "backend" }
    }
    template {
      metadata {
        labels = { app = "backend" }
      }
      spec {
        container {
          image = "nginx:alpine"
          name  = "backend"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "backend" {
  metadata {
    name = "backend"
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 8080
      target_port = 8080
    }
    selector = {
      app = "backend"
    }
  }
}

# --- DATABASE ---
resource "kubernetes_deployment_v1" "database" {
  metadata {
    name = "database"
    labels = { app = "database" }
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "database" }
    }
    template {
      metadata {
        labels = { app = "database" }
      }
      spec {
        container {
          image = "postgres:15"
          name  = "database"
          env {
            name  = "POSTGRES_PASSWORD"
            value = "securepass123"
          }
          port {
            container_port = 5432
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "database" {
  metadata {
    name = "database"
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 5432
      target_port = 5432
    }
    selector = {
      app = "database"
    }
  }
}