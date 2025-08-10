# bundacare

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Tentu, ini adalah penyempurnaan dari *prompt* Anda, yang telah dilengkapi berdasarkan analisis detail dari desain UI aplikasi **BundaCare**.

*Prompt* yang sudah lengkap ini memberikan konteks yang jauh lebih kaya kepada AI, menjelaskan tidak hanya "apa" yang harus dibuat, tetapi juga "bagaimana" fitur-fitur tersebut saling berhubungan sesuai dengan alur di UI Anda.

***

### ✅ Prompt Lengkap untuk Proyek Aplikasi Flutter BundaCare

**Peran:** Kamu adalah seorang **Pengembang Aplikasi Flutter Senior** yang ahli dalam Clean Architecture, state management menggunakan BLoC, dan integrasi dengan Supabase.

**Tujuan:** Hasilkan struktur proyek awal dan kode boilerplate untuk aplikasi Flutter baru berdasarkan spesifikasi di bawah ini. Pastikan kode yang dihasilkan mengikuti praktik terbaik, mudah dibaca, dan siap untuk pengembangan lebih lanjut.

---

### **1. Ringkasan Proyek**

* **Nama Aplikasi:** `BundaCare`
* **Deskripsi Singkat:** Aplikasi untuk memonitor dan melacak asupan nutrisi harian ibu hamil melalui deteksi makanan via foto.
* **Target Pengguna:** Ibu hamil yang ingin memastikan kebutuhan nutrisi janin dan dirinya terpenuhi dengan baik.

---

### **2. Spesifikasi Teknis**

* **Framework:** Flutter (versi terbaru)
* **Backend as a Service (BaaS):** Supabase
* **Arsitektur:** Clean Architecture. Buatkan struktur direktori yang memisahkan **Presentation** (UI dan State Management), **Domain** (Entities, Use Cases, Repositories), dan **Data** (Data Sources, Models, Repositories Implementation).
* **State Management:** **BLoC (Business Logic Component)**. Gunakan package `flutter_bloc`.
* **Navigasi:** Gunakan `GoRouter` untuk routing berbasis path (URL-based).
* **Dependency Injection:** Gunakan `get_it` untuk service locator.
* **Konektivitas:** Gunakan package `dio` untuk mengirim gambar ke model ML.
* **Testing:** Siapkan struktur dasar untuk unit testing, widget testing, dan integration testing.

---

### **3. Desain & Fitur Utama**

Saya sudah menyelesaikan seluruh desain UI/UX. Berdasarkan desain tersebut, berikut adalah fitur-fitur utama yang perlu diimplementasikan:

**a. Autentikasi & Profil Pengguna**
* **Autentikasi (Supabase Auth):**
    * Pengguna mendaftar dan masuk hanya menggunakan **Google OAuth**.
    * Sesi pengguna harus tetap aktif (persisten) setelah aplikasi ditutup.
* **Manajemen Profil (`profiles`):**
    * **Tabel Supabase `profiles`:** Terhubung dengan `auth.users` via `user_id`.
    * **Kolom Tabel `profiles`:** `id (UUID, primary key)`, `full_name (text)`, `avatar_url (text)`, `pregnancy_start_date (date)`. Kolom `pregnancy_start_date` penting untuk menghitung usia kehamilan dan menampilkan trimester yang sesuai di Home Screen.
    * **Fitur:** Pengguna dapat melihat profil dan melakukan logout. (Fitur edit profil bisa diimplementasikan nanti).

**b. Fitur Utama 1: Deteksi & Pencatatan Makanan**
* **Deskripsi Fitur:** Pengguna mengambil foto makanan, aplikasi mengunggahnya, mengirimnya ke endpoint eksternal untuk deteksi nutrisi, lalu menampilkan hasilnya untuk dicatat.
* **Alur Fitur:**
    1.  Pengguna menekan tombol kamera di **Home Screen**.
    2.  Membuka **Camera Screen** untuk mengambil foto.
    3.  Setelah foto diambil, navigasi ke **Detect Screen**.
    4.  Aplikasi mengunggah gambar ke **Supabase Storage** dalam bucket bernama `food_images`.
    5.  Aplikasi mengirimkan *public URL* gambar tersebut ke endpoint `https://fotota.site/predict` menggunakan `POST request`.
    6.  Aplikasi menerima hasil deteksi (nama makanan, kalori, protein, lemak, karbohidrat).
    7.  Hasil ditampilkan di **Detect Screen**. Saat pengguna menekan tombol simpan, data akan dimasukkan ke tabel `food_logs`.
* **Tabel Supabase `food_logs`:**
    * **Kolom:** `id (bigint, primary key)`, `user_id (UUID, foreign key)`, `food_name (text)`, `image_url (text)`, `calories (numeric)`, `protein (numeric)`, `fat (numeric)`, `carbohydrate (numeric)`, `created_at (timestamp with time zone)`.

**c. Fitur Utama 2: Monitoring & Riwayat Nutrisi**
* **Deskripsi Fitur:** Menampilkan rekapitulasi nutrisi harian di Home Screen dan riwayat lengkap di History Screen.
* **Fungsionalitas:**
    * **Home Screen:**
        * Menampilkan trimester kehamilan saat ini (dihitung dari `pregnancy_start_date`).
        * Menampilkan **total akumulasi** `calories`, `protein`, `fat`, dan `carbohydrate` dari tabel `food_logs` dengan filter `user_id` dan `created_at` untuk hari ini.
        * Menampilkan daftar makanan yang dikonsumsi hari ini.
    * **History Screen:**
        * Menampilkan semua data dari tabel `food_logs` untuk pengguna yang sedang login, dikelompokkan berdasarkan tanggal.
    * **Detail Screen:**
        * Membuka halaman ini saat salah satu item riwayat di-klik, menampilkan detail nutrisi dari item tersebut.
    * **Delete:** Pengguna dapat menghapus entri makanan dari log mereka (misalnya dengan swipe-to-delete).

---

### **4. Tugas Awal & Struktur Kode**

Berdasarkan informasi di atas, lakukan tugas-tugas berikut:

1.  **Inisialisasi Proyek:**
    * Buat struktur direktori proyek Flutter sesuai **Clean Architecture**.
    * Tambahkan semua dependensi yang disebutkan ke `pubspec.yaml`.

2.  **Konfigurasi Supabase:**
    * Buat file untuk inisialisasi Supabase Client.

3.  **Implementasi Autentikasi & Profil:**
    * Buat **Use Cases**, **Repository**, dan **BLoC** untuk proses Login dengan Google dan mengambil data profil.
    * Buat halaman UI **Login Screen** & **Profile Screen**.

4.  **Implementasi Fitur Inti:**
    * Buat **Use Cases**, **Repository**, dan **BLoC** untuk:
        * Mengunggah gambar ke Supabase Storage.
        * Mengirim URL ke endpoint deteksi.
        * Menyimpan, mengambil, dan menghapus data dari tabel `food_logs`.
    * Buat kerangka UI untuk **Home, Camera, Detect, History,** dan **Detail Screen**.

5.  **Routing Awal:**
    * Konfigurasikan `GoRouter` untuk rute: `/`, `/login`, `/profile`, `/history`, `/detail/:log_id`.
    * Implementasikan *redirect logic*: jika belum login, paksa ke `/login`.

6.  **SQL Skema:**
    * Sediakan skrip SQL untuk membuat tabel **`profiles`** dan **`food_logs`**, beserta kebijakan **Row Level Security (RLS)** yang sesuai (pengguna hanya bisa mengakses dan mengubah datanya sendiri).