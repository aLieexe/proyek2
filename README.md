# Proyek 2: Deployment Kubernetes Aman dengan Terraform & Network Policy

Proyek ini mendemonstrasikan deployment aplikasi multi-tier (frontend → backend → database) di klaster Kubernetes menggunakan Terraform. Fokus utama adalah menerapkan kebijakan jaringan internal (NetworkPolicy) untuk menerapkan prinsip zero-trust, memastikan bahwa hanya komunikasi yang diizinkan yang dapat terjadi antar pod.

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
- **Konfigurasi Variabel:** Port, image container, dan credential database disimpan dalam variabel Terraform.
- **Persistent Storage:** Data PostgreSQL disimpan menggunakan PersistentVolumeClaim (PVC) untuk persistensi data.

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
      --container-runtime=containerd \
      --kubernetes-version=v1.31.0 \
      --network-plugin=cni \
      --cni=calico
    ```

## Deployment

1.  **Konfigurasi Variabel:**
    - Buat file `terraform.tfvars` di dalam folder aplikasi multi-tier dengan isi:
      ```bash
      database_username = "User_Anda"
      database_password = "Sandi_Anda"
      ```
      
2.  **Inisialisasi Terraform:**
    ```bash
    terraform init
    ```

3.  **Validasi Konfigurasi:**
    ```bash
    terraform validate
    ```

4.  **Terapkan Konfigurasi:**
    ```bash
    terraform apply -auto-approve
    ```

## Akses Aplikasi Frontend

1.  **Dapatkan URL Frontend:**
    ```bash
    minikube service frontend --url
    ```
    Atau, akses langsung melalui `http://localhost:<NodePort>`. Port NodePort bisa dilihat di output `kubectl get services`.

## Testing Zero-Trust Network Policy

1.  **Dapatkan Nama Pod:**
    ```bash
    kubectl get pods
    ```

2.  **[IZIN] Uji Akses dari Frontend ke Backend:**
    ```bash
    kubectl exec -it $FRONTEND_POD -- curl -v http://backend:8080
    ```
    Harus menampilkan halaman HTML dari nginx backend.

3.  **[IZIN] Uji Akses dari Backend ke Database:**
    ```bash
    kubectl exec -it $BACKEND_POD -- curl -v -m 5 http://database:5432
    ```
    Harus menunjukkan `Connected to database...` dan `Empty reply from server` (karena bukan HTTP).

4.  **[DIBLOKIR] Uji Akses dari Frontend ke Database:**
    ```bash
    kubectl exec -it $FRONTEND_POD -- curl -v -m 5 http://database:5432
    ```
    Harus menunjukkan `Connection timed out after 5000 milliseconds`.

Jika semua pengujian berjalan sesuai harapan, maka `NetworkPolicy` telah berhasil diterapkan.

## Test Persistensi Data (VPC)

1.  **Masuk ke Pod Database:**
    ```bash
    kubectl exec -it $DATABASE_POD -- bash
    ```
    
2.  **Set Password dan Buat Database Dummy:**
    Gunakan user dan sandi yang telah di set dengan nilai dari `terraform.tfvars` Anda.
    ```bash
    # Di dalam pod:
    export PGPASSWORD="Sandi_Anda" # Ganti dengan sandi Anda
    psql -U User_Anda -c "CREATE DATABASE TEST_PERSIST;"
    psql -U User_Anda -c "\l" # Lihat daftar database, pastikan 'TEST_PERSIST' ada
    exit 
    ```
    
3.  **Hapus Pod Database:**
    ```bash
    kubectl delete pod $DATABASE_POD
    ```
    
4.  **Tunggu Pod Baru Siap:**
    ```bash
    kubectl get pods # Tunggu hingga Running
    ```

5.  **Masuk ke Pod *Baru* dan Cek Data:**
    ```bash
    kubectl exec -it <nama-pod-database-baru> -- bash
    # Di dalam pod:
    export PGPASSWORD="Sandi_Anda"
    psql -U User_Anda -c "\l" # Cek database TEST_PERSIST
    exit
    ```
    Jika database `TEST_PERSIST` **MASIH ADA**, maka **PVC berfungsi dengan baik**.    
