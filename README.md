# Proyek 2: Deployment Kubernetes Aman dengan Terraform & Network Policy

Proyek ini mendemonstrasikan deployment aplikasi multi-tier (frontend → backend → database) di cluster Kubernetes menggunakan Terraform. Fokus utama adalah menerapkan kebijakan jaringan internal (NetworkPolicy) untuk menerapkan prinsip zero-trust, memastikan bahwa hanya komunikasi yang diizinkan yang dapat terjadi antar pod.

## Arsitektur

Aplikasi terdiri dari tiga komponen utama:

- **Frontend:** [Repository](https://github.com/aLieexe/pastebin-frontend) - [Dockerhub](https://hub.docker.com/r/alie12/pastebin-frontend)`alie12/pastebin-frontend:kubernetes` 
- **Backend:** [Repository](https://github.com/aLieexe/pastebin-backend) - [Dockerhub](hub.docker.com/r/alie12/pastebin-backend)`alie12/pastebin-backend:kubernetes`
- **Database:** Server PostgreSQL (`postgres:17`)

## Fitur Utama

- **Infrastructure as Code (IaC):** Menggunakan Terraform untuk mendefinisikan dan mengelola infrastruktur Kubernetes.
- **Network Policy (Zero-Trust):**
  - `frontend` hanya boleh diakses dari `public` (melalui NodePort).
  - `backend` hanya boleh diakses oleh pod `frontend`.
  - `database` hanya boleh diakses oleh pod `backend`.
- **Konfigurasi Variabel:** Port, image container, dan credential database disimpan dalam variabel Terraform.
- **Persistent Storage:** Data PostgreSQL disimpan menggunakan PersistentVolumeClaim (PVC) untuk persistensi data.
- **Isolasi Namespace**: Setiap komponen berjalan di namespace terpisah

## Setup Lingkungan

1.  **Install Prasyarat:**
    - Ikuti dokumentasi resmi untuk menginstal
    - [Docker](https://docs.docker.com/engine/install/)
    - [kubectl](https://kubernetes.io/docs/tasks/tools/)
    - [Minikube](https://minikube.sigs.k8s.io/docs/start/)
    - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

2.  **Start Klaster Minikube:**
    Jalankan perintah berikut untuk membuat klaster Minikube dengan CNI Calico (diperlukan untuk NetworkPolicy).
    ```bash
    minikube start \
    --driver=docker \
    --container-runtime=docker \
    --kubernetes-version=v1.31.0
    ```

3.  **Pasang CNI:**
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/calico.yaml
    ```

## Deployment

1.  **Konfigurasi Variabel:**
    Check file `terraform.tfvars` ganti variable seperti password, user menjadi ke yang diinginkan:
      
2.  **Aktifkan Minikube Tunnel (Apabila menggunakan WSL)**
    ```bash
    minikube tunnel
    ```
    
3.  **Inisialisasi Terraform:**
    ```bash
    terraform init
    ```

4.  **Validasi Konfigurasi:**
    ```bash
    terraform plan
    ```
    ```bash
    terraform validate
    ```

5.  **Terapkan Konfigurasi:**
    ```bash
    terraform apply -auto-approve
    ```

6. **Verifikasi Resource:**
   ```bash
   kubectl get all -A
   kubectl get networkpolicy -A
   ```
## Akses Aplikasi Frontend

1.  **Dapatkan URL Frontend:**
    ```bash
    minikube service frontend -n frontend-ns --url
    ```
    Gunakan IP yang didapat untuk mengakses webpage service frontend

## Testing

1.  **Dapatkan Nama Pod:**
    ```bash
    kubectl get pods -A
    ```
    Copy
    ```bash
    FPOD=$(kubectl get pod -n frontend-ns -l app=frontend -o jsonpath='{.items[0].metadata.name}')
    BPOD=$(kubectl get pod -n backend-ns -l app=backend -o jsonpath='{.items[0].metadata.name}')
    DPOD=$(kubectl get pod -n database-ns -l app=database -o jsonpath='{.items[0].metadata.name}')
    ```

2.  **[IZIN] Uji Akses dari Frontend ke Backend:**
    ```bash
    kubectl exec -n frontend-ns $FPOD -- curl -s http://backend.backend-ns.svc.cluster.local:8080 | head -3
    ```
    Output <!DOCTYPE html>

3.  **[IZIN] Uji Akses dari Backend ke Database:**
    ```bash
    kubectl exec -n backend-ns $BPOD -- curl -v -m 5 http://database.database-ns.svc.cluster.local:5432
    ```
    Output `Connected to database...` dan `Empty reply from server` (karena bukan HTTP).

4.  **[DIBLOKIR] Uji Akses dari Frontend ke Database:**
    ```bash
    kubectl exec -n frontend-ns $FPOD -- timeout 10 curl -v http://database.database-ns.svc.cluster.local:5432
    ```
    Output `command terminated with exit code 124` (Timeout)

Jika semua pengujian berjalan sesuai harapan, maka `NetworkPolicy` telah berhasil diterapkan.

## Test Persistensi Data (VPC)

1.  **Buat Database Dummy:**
    ```bash
    kubectl exec -n database-ns $DPOD -- psql -U (Username Anda) -c "CREATE DATABASE persist;"
    ```
    
2.  **Hapus Pod Database:**
    ```bash
    kubectl delete pod -n database-ns $DPOD
    ```
    
3.  **Tunggu Pod Baru Siap:**
    ```bash
    kubectl get pods -A # Tunggu hingga Running
    ```
    Copy ulang setelah pod database berjalan
    ```bash
    DPOD_NEW=$(kubectl get pod -n database-ns -l app=database -o jsonpath='{.items[0].metadata.name}')
    ```

4.  **Verifikasi Database:**
    ```bash
    kubectl exec -n database-ns $DPOD_NEW -- psql -U PTCPM -c "\l" | grep persist
    ```
    Jika database `TEST_PERSIST` **MASIH ADA**, maka **PVC berfungsi dengan baik**.

5.  **Tampilkan Credential Database: (Apabila Diperlukan)**
    ```bash
    kubectl exec -n database-ns $DPOD_NEW -- env | grep -E "(POSTGRES_USER|POSTGRES_PASSWORD)"
    ```
