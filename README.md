# BundaCare Mobile App

Aplikasi mobile BundaCare untuk memantau asupan nutrisi ibu hamil dengan deteksi makanan.

### 📝 Deskripsi Proyek

BundaCare adalah aplikasi mobile yang dibangun menggunakan Flutter untuk membantu ibu hamil memonitor dan melacak asupan nutrisi harian mereka. Dengan fitur deteksi makanan menggunakan kcerdasan buatan (AI), aplikasi ini memudahkan pengguna untuk memastikan kebutuhan nutrisi janin dan dirinya terpenuhi dengan baik.

-----

### ✨ Fitur-fitur Utama

  - **Autentikasi Pengguna**: Login dan registrasi mudah dengan Google OAuth menggunakan Supabase Auth.
  - **Deteksi & Pencatatan Makanan**: Mengambil foto makanan, mengunggahnya ke Supabase Storage, dan menggunakan API eksternal (`fotota.site/predict`) untuk mendeteksi nutrisi.
  - **Log Nutrisi Harian**: Menyimpan data nutrisi ke dalam tabel `food_logs` di Supabase.
  - **Riwayat & Monitoring**: Menampilkan ringkasan nutrisi harian dan riwayat lengkap yang bisa diakses per tanggal.
  - **Manajemen Profil**: Pengguna dapat melihat dan memperbarui tanggal awal kehamilan mereka, yang digunakan untuk menghitung trimester.
  - **UI & UX Modern**: Menggunakan desain yang bersih, *dark mode*, dan navigasi yang intuitif.

-----

### 📷 Tampilan Aplikasi

Berikut adalah beberapa tampilan utama dari aplikasi BundaCare:

*Tampilan Home Screen dengan ringkasan nutrisi harian.*

*Tampilan Modal Deteksi Makanan.*

-----

### 🧱 Arsitektur & Teknologi

Aplikasi ini dibangun dengan mengikuti **Clean Architecture** untuk memastikan kode yang terstruktur, mudah diuji, dan *scalable*.

  - **Framework**: Flutter (versi terbaru)
  - **Backend as a Service (BaaS)**: [Supabase](https://supabase.com)
      - Supabase Auth (Google OAuth)
      - Supabase Database (PostgreSQL)
      - Supabase Storage
  - **Arsitektur**: Clean Architecture
  - **State Management**: [BLoC (Business Logic Component)](https://pub.dev/packages/flutter_bloc)
  - **Navigasi**: [GoRouter](https://pub.dev/packages/go_router)
  - **Dependency Injection**: [get\_it](https://pub.dev/packages/get_it)
  - **Networking**: [dio](https://pub.dev/packages/dio)
  - **Assets & Styling**:
      - [flutter\_svg](https://pub.dev/packages/flutter_svg)
      - [iconsax](https://www.google.com/search?q=https://pub.dev/packages/iconsax)
      - Font kustom: Poppins
  - **Native Tools**:
      - [flutter\_launcher\_icons](https://pub.dev/packages/flutter_launcher_icons)
      - [flutter\_native\_splash](https://pub.dev/packages/flutter_native_splash)

-----

### 📂 Struktur Proyek

Berikut adalah gambaran singkat struktur direktori yang digunakan:

```
lib/
├── core/
│   ├── config/             # Konfigurasi aplikasi (router, dll)
│   ├── injection_container.dart  # Dependency Injection
│   ├── services/           # Service eksternal (Supabase, Nutrition)
│   └── utils/              # Fungsi utilitas
│
├── data/
│   ├── datasources/        # Implementasi sumber data (remote API)
│   ├── models/             # Konversi data (JSON ke model)
│   └── repositories/       # Implementasi repository
│
├── domain/
│   ├── entities/           # Class data inti aplikasi
│   ├── repositories/       # Kontrak repository (abstraksi)
│   └── usecases/           # Logika bisnis inti
│
└── presentation/
    ├── bloc/               # State management (BLoC)
    ├── screens/            # Tampilan/halaman aplikasi
    └── widgets/            # Widget yang bisa digunakan kembali
```

-----

### 🚀 Cara Menjalankan Proyek

1.  **Clone repositori:**

    ```bash
    git clone https://github.com/your-username/bundacare.git
    cd bundacare
    ```

2.  **Dapatkan dependensi:**

    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Supabase:**

      * Siapkan proyek Supabase Anda.
      * Buat file `main.dart` Anda dan ganti `YOUR_SUPABASE_URL` dan `YOUR_SUPABASE_ANON_KEY` dengan kunci Anda.

4.  **Jalankan aplikasi:**

    ```bash
    flutter run
    ```

-----

### ✅ Yang Sudah Selesai & Rencana Ke Depan

  - [x] Autentikasi Google dengan Supabase.
  - [x] Struktur proyek Clean Architecture.
  - [x] Navigasi dengan GoRouter.
  - [x] Tampilan Home Screen dengan ringkasan nutrisi & riwayat.
  - [x] Tampilan Profile Screen dengan menu dan fungsionalitas update tanggal kehamilan.
  - [x] Tampilan Camera Screen dengan kontrol modern.
  - [x] Alur deteksi makanan (ambil gambar -\> API -\> tampilkan hasil).
  - [x] Alur penyimpanan log makanan ke Supabase.
  - [x] Konfigurasi ikon aplikasi dan *splash screen*.

### 💡 Peningkatan Lanjutan

  * Implementasi halaman notifikasi.
  * Implementasi halaman riwayat penyakit dan FAQ.
  * Tambahkan fungsionalitas edit profil pengguna.
  * Menerapkan *testing* (unit, widget, dan integration testing) untuk BLoC dan *use cases*.