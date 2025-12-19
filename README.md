# Proyek 2: Deployment Kubernetes Aman dengan Terraform & Network Policy

Proyek ini mendemonstrasikan deployment aplikasi multi-tier (frontend → backend → database) di klaster Kubernetes menggunakan Terraform. 
Fokus utama adalah menerapkan kebijakan jaringan internal (NetworkPolicy) untuk menerapkan prinsip zero-trust, 
memastikan bahwa hanya komunikasi yang diizinkan yang dapat terjadi antar pod.

## Arsitektur

Aplikasi terdiri dari tiga komponen utama:

- **Frontend:** Server web Nginx (`nginx:latest`)
- **Backend:** Server web Nginx (`nginx:latest`)
- **Database:** Server PostgreSQL (`postgres:15`)

## Fitur Utama

- **Infrastructure as Code (IaC):** Menggunakan Terraform untuk mendefinisikan dan mengelola infrastruktur Kubernetes.
- **Network Policy (Zero-Trust):**
  - `frontend` hanya boleh diakses dari `public` (melalui NodePort).
  - `backend` hanya boleh diakses oleh pod `frontend`.
  - `database` hanya boleh diakses oleh pod `backend`.
