variable "frontend_port" {
  description = "Port eksternal frontend"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Port eksternal backend"
  type        = number
  default     = 8080
}

variable "backend_container_port" {
  description = "Port internal (container) backend"
  type        = number
  default     = 80
}

variable "database_port" {
  description = "Port eksternal database"
  type        = number
  default     = 5432
}

variable "frontend_image" {
  description = "Image container frontend"
  type        = string
  default     = "nginx:latest"
}

variable "backend_image" {
  description = "Image container backend"
  type        = string
  default     = "nginx:latest"
}

variable "database_image" {
  description = "Image container database"
  type        = string
  default     = "postgres:15"
}

variable "database_username" {
  description = "Username untuk database"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Password untuk database"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "database_host" {
  type        = string
  description = "Database hostname or service DNS"
}


variable "database_name" {
  type        = string
  description = "Database name"
}
