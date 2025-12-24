backend_image       = "alie12/pastebin-backend:kubernetes"
frontend_image      = "alie12/pastebin-frontend:kubernetes"
database_image      = "postgres:17"

database_host     = "database.database-ns.svc.cluster.local"
database_port     = 5432
database_username = "alie"
database_password = "12345678"
database_name     = "pastebin_db"

// Listen on 8080
backend_container_port = 8080

// Map it to the pod on 8080
backend_port           = 8080
frontend_port          = 80


