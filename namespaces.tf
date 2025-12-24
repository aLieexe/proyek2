# namespaces.tf

resource "kubernetes_namespace_v1" "frontend_ns" {
  metadata {
    name = "frontend-ns"
    labels = {
      team = "frontend-team"
    }
  }
}

resource "kubernetes_namespace_v1" "backend_ns" {
  metadata {
    name = "backend-ns"
    labels = {
      team = "backend-team"
    }
  }
}

resource "kubernetes_namespace_v1" "database_ns" {
  metadata {
    name = "database-ns"
    labels = {
      team = "database-team"
    }
  }
}