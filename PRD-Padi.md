# Product Requirements Document (PRD)
## Aplikasi Mobile Klasifikasi Penyakit Daun Padi Berbasis AI (*Offline-First*)

---

## 1. Informasi Umum Proyek

| Atribut | Detail |
| :--- | :--- |
| **Opsi Nama Aplikasi** | **CekPadi** *(Rekomendasi Utama)*
| **Pengembang** | Romi Setiawan (D4 Rekayasa Perangkat Lunak — Politeknik Negeri Indramayu) |
| **Platform Target** | Android (Flutter, siap rilis Google Play Store) |
| **Arsitektur Sistem** | 100% *Offline-First* (On-Device AI, tanpa Server Backend/VPS) |
| **Model AI** | MobileNetV2 Multi-Domain (`model_padi_multidomain.tflite`, 2,55 MB) |
| **Tanggal Dokumen** | 23 November 2026 |
| **Target Selesai (MVP)** | Pertengahan Desember 2026 (14–15 Desember 2026) |

### Pertimbangan Pemilihan Nama Aplikasi
1. **CekPadi** *(Rekomendasi)* — Singkat, membumi, langsung dimengerti petani, dan mudah dicari di Play Store.
2. **PadiCare** — Terdengar modern dan profesional untuk presentasi skripsi.
3. **PadiScan** — Langsung menjelaskan mekanisme utama aplikasi (memindai daun padi).
4. **SiPadi** *(Sistem Identifikasi Penyakit Padi)* — Khas penamaan aplikasi lokal Indonesia.
5. **PadiSehat** — Menekankan tujuan akhir yang diinginkan petani.

---

## 2. Latar Belakang & Tujuan

### Latar Belakang
Penyakit pada tanaman padi sering kali terlambat ditangani karena petani kesulitan membedakan gejala visual antarpenyakit secara akurat di lapangan. Di sisi lain, kondisi area persawahan umumnya memiliki koneksi internet yang tidak stabil. Oleh karena itu, dibutuhkan aplikasi mobile yang mampu mendeteksi penyakit daun padi secara cepat, akurat, dan dapat bekerja sepenuhnya tanpa koneksi internet.

### Tujuan Produk
* Membantu petani dan penyuluh pertanian mengidentifikasi 4 penyakit utama daun padi serta kondisi daun sehat langsung dari kamera ponsel.
* Memberikan informasi gejala, penyebab, dan rekomendasi penanganan awal secara instan dan *offline*.
* Menyediakan dokumentasi riwayat pemeriksaan tanaman secara lokal di perangkat pengguna.
* Memenuhi kebutuhan luaran tugas akhir (skripsi) D4 Rekayasa Perangkat Lunak dengan arsitektur perangkat lunak yang efisien dan siap pakai.

---

## 3. Target Pengguna (*User Persona*)

1. **Petani Padi:** Membutuhkan antarmuka yang sangat sederhana, tombol besar, bahasa Indonesia yang mudah dipahami, dan tidak bergantung pada kuota/sinyal internet di sawah.
2. **Penyuluh Pertanian Lapangan (PPL):** Membutuhkan alat bantu cepat untuk validasi gejala penyakit di lapangan dan menyimpan riwayat foto kondisi sawah.
3. **Mahasiswa / Akademisi Pertanian:** Membutuhkan referensi visual dan edukasi mengenai gejala penyakit daun padi.

---

## 4. Ruang Lingkup & Batasan Sistem

### Kelas yang Didukung (5 Kelas)
1. **Hawar Daun Bakteri / Kresek** (`Bacterial_Leaf_Blight`)
2. **Bercak Cokelat** (`Brown_Spot`)
3. **Blas Daun** (`Leaf_Blast`)
4. **Virus Tungro** (`Tungro`)
5. **Daun Sehat** (`Healthy`)

### Batasan Sistem (*Out of Scope*)
* **Bukan Detektor Hama:** Aplikasi tidak mendeteksi serangga/hama (seperti wereng, belalang, atau ulat), melainkan hanya gejala kerusakan pada helai daun.
* **Di Luar 5 Kelas:** Penyakit padi lain (seperti *Leaf Scald*, hawar pelepah, atau kerusakan akar/bulir) dan masalah kekurangan nutrisi/pupuk tidak termasuk dalam cakupan klasifikasi.
* **Tanpa Backend & Autentikasi:** Tidak ada fitur *login*, sinkronisasi *cloud*, atau penyimpanan data di server eksternal. Semua data dan foto disimpan di penyimpanan internal perangkat pengguna.

---

## 5. Spesifikasi Model AI (*On-Device*)

* **File Model:** `assets/models/model_padi_multidomain.tflite` (2,55 MB)
* **File Label:** `assets/models/labels_multidomain.txt`
* **Performa Evaluasi:** Akurasi Validasi **91,36%**, F1-Score **91,36%** (Dataset *multi-domain* 5.000 citra: campuran foto sawah asli & latar polos, rasio 75:25).
* **Input Tensor:** Shape `(1, 224, 224, 3)`, tipe `float32`, rentang nilai piksel `0.0` hingga `255.0` *(normalisasi `Rescaling` sudah tertanam di dalam model)*.
* **Output Tensor:** Shape `(1, 5)`, tipe `float32` (probabilitas *softmax* untuk 5 kelas).
* **Aturan Ambang Batas Keyakinan (*Confidence Threshold*):**
  * **Keyakinan $\ge 75\%$:** Tampilkan hasil diagnosis utama secara tegas beserta rekomendasi penanganannya.
  * **Keyakinan $< 75\%$:** Tampilkan status **"Keyakinan Rendah / Perlu Foto Ulang"**, tampilkan **2 kemungkinan penyakit teratas**, dan berikan saran agar pengguna memfoto atau memotong (*crop*) lebih dekat ke satu helai daun yang bergejala.

---

## 6. Fitur Utama & Kebutuhan Fungsional

### F1. Halaman Beranda (*Home Dashboard*)
* Menampilkan sambutan singkat, ringkasan jumlah riwayat pemeriksaan, dan tombol aksi utama yang mencolok: **"Ambil Foto (Kamera)"** dan **"Pilih dari Galeri"**.
* Menampilkan kartu **Tips Pengambilan Foto Akurat** (misalnya: fokus pada 1 helai daun bergejala, pencahayaan cukup, tidak buram).
* Menampilkan daftar singkat 3 riwayat pemeriksaan terakhir.

### F2. Pengambilan Gambar & *Crop* Persegi (1:1)
* Pengguna memilih foto dari kamera atau galeri (`image_picker`).
* Sebelum diproses oleh AI, aplikasi **wajib** membuka layar pemotongan gambar (`image_cropper`) dengan rasio terkunci **1:1 (persegi)** agar:
  * Gambar tidak mengalami distorsi (*stretch*) saat di-*resize* ke `224x224`.
  * Pengguna dapat memfokuskan bingkai tepat pada area daun yang memiliki bercak/gejala.

### F3. Deteksi Penyakit *Offline* (Inferensi TFLite)
* Mengubah gambar hasil *crop* menjadi ukuran `224x224` piksel dan menjalankan inferensi melalui `tflite_flutter` secara *offline*.
* Menampilkan indikator *loading* singkat saat memproses.
* Menerapkan logika *Confidence Threshold* ($75\%$).

### F4. Halaman Hasil Deteksi & Rekomendasi Penanganan
* Menampilkan foto daun hasil *crop*.
* Menampilkan nama penyakit dalam Bahasa Indonesia & nama ilmiah/Inggris, tingkat keyakinan dalam persentase (beserta *progress bar*), dan label status (*Sehat* / *Terindikasi Penyakit* / *Keyakinan Rendah*).
* Menampilkan rincian probabilitas kelas lain (opsional dalam *expandable card* untuk keperluan evaluasi skripsi).
* Menampilkan **Panduan Lengkap Penanganan** (disimpan lokal di dalam aplikasi):
  * Penyebab (Bakteri / Jamur / Virus)
  * Ciri-ciri Gejala
  * Langkah Pencegahan
  * Rekomendasi Pengendalian (Kultur teknis, biologis, dan referensi bahan aktif fungisida/bakterisida/insektisida vektor secara umum).
* Otomatis menyimpan hasil ke riwayat lokal (dengan opsi hapus jika pengguna tidak ingin menyimpannya).

### F5. Riwayat Pemeriksaan Lokal (*History*)
* Menyimpan file gambar hasil *crop* ke direktori internal aplikasi (`getApplicationDocumentsDirectory/history_images/`) agar tidak mengotori galeri utama pengguna.
* Menyimpan metadata deteksi ke database lokal SQLite (`sqflite`).
* Pengguna dapat melihat daftar riwayat berdasarkan waktu terbaru, membuka kembali halaman detail hasil, dan menghapus riwayat (baik data di SQLite maupun file gambarnya agar penyimpanan tidak penuh).

### F6. Ensiklopedia Penyakit Padi (*Info Penyakit*)
* Halaman katalog statis yang menampilkan daftar 5 kondisi daun padi (4 penyakit + 1 sehat) lengkap dengan contoh foto dan panduan penanganannya, sehingga pengguna dapat membaca informasi kapan saja tanpa harus melakukan *scan*.

### F7. Halaman Tentang Aplikasi & Batasan Sistem
* Menampilkan informasi pengembang, teknologi yang digunakan (MobileNetV2 + TFLite), versi aplikasi, serta penjelasan transparan mengenai **Batasan Sistem** dan *disclaimer* bahwa aplikasi merupakan alat bantu deteksi awal.

---

## 7. Alur Pengguna (*User Flow*)

```text
[Buka Aplikasi] 
       │
       ▼
[Halaman Beranda] ──► [Tab Riwayat] ──► [Detail Riwayat / Hapus]
       │          ──► [Tab Info Penyakit] ──► [Detail Ensiklopedia]
       │
       ▼ (Klik Kamera / Galeri)
[Ambil / Pilih Foto Daun Padi]
       │
       ▼
[Layar Crop Persegi 1:1 (Fokus ke Bercak Daun)]
       │
       ▼
[Proses Inferensi Offline (MobileNetV2 TFLite)]
       │
       ├──► (Jika Keyakinan >= 75%) ──► [Tampil Diagnosis Utama + Rekomendasi Penanganan]
       │                                           │
       └──► (Jika Keyakinan < 75%)  ──► [Peringatan Keyakinan Rendah + Top-2 Kemungkinan + Tombol Foto Ulang]
                                                   │
                                                   ▼
                                     [Simpan Foto & Data ke Penyimpanan Lokal HP]
```

---

## 8. Kebutuhan Non-Fungsional

* **Ketersediaan (*Offline*):** 100% fitur inti dapat berjalan tanpa koneksi internet (Mode Pesawat).
* **Performa:** Waktu inferensi model di perangkat Android kelas menengah maksimal $< 1$ detik (target $100\text{--}400\text{ ms}$).
* **Ukuran Aplikasi:** Target ukuran APK rilis ringan (di bawah 30–40 MB).
* **Usabilitas (UI/UX):** Desain bersih bertema hijau pertanian yang nyaman di bawah sinar matahari, tipografi jelas, navigasi maksimal 3–4 tab bawah (*Bottom Navigation Bar*).
* **Privasi:** Tidak ada pengumpulan data pribadi atau pengunggahan gambar ke pihak ketiga (ramah kebijakan Google Play Store).

---

## 9. Arsitektur Teknis & *Tech Stack*

* **Framework:** Flutter (Dart, Material 3)
* **State Management:** `setState` / `Provider` (cukup sederhana dan mudah dirawat untuk skala MVP)
* **Daftar Package Utama (`pubspec.yaml`):**
  * `tflite_flutter` — Menjalankan model `.tflite` secara lokal.
  * `image` — Decode dan *resize* gambar ke `224x224` piksel.
  * `image_picker` — Akses kamera dan galeri.
  * `image_cropper` — Pemotongan gambar rasio 1:1 sebelum deteksi.
  * `sqflite` — Database lokal untuk menyimpan riwayat.
  * `path_provider` & `path` — Manajemen direktori lokal untuk menyimpan foto riwayat.
  * `intl` — Format tanggal & waktu Bahasa Indonesia.

### Rencana Struktur Folder (`lib/`)
```text
lib/
├── main.dart
├── data/
│   ├── disease_data.dart          # Data statis 5 kelas (gejala, penyebab, penanganan)
│   └── database_helper.dart       # CRUD SQLite untuk riwayat lokal
├── models/
│   └── detection_record.dart      # Model data hasil deteksi
├── services/
│   ├── classifier_service.dart    # Load TFLite, preprocessing 224x224, inferensi
│   └── image_storage_service.dart # Simpan & hapus file gambar di folder lokal HP
└── screens/
    ├── main_navigation.dart       # Bottom Navigation (Beranda, Riwayat, Info, Tentang)
    ├── home_screen.dart           # Beranda + tombol Kamera/Galeri + Tips Foto
    ├── result_screen.dart         # Hasil deteksi, threshold, & rekomendasi penanganan
    ├── history_screen.dart        # Daftar riwayat deteksi lokal
    ├── encyclopedia_screen.dart   # Katalog 5 kondisi daun padi
    └── about_screen.dart          # Info skripsi & batasan sistem
```

---

## 10. Skema Database Lokal (SQLite)

**Nama Tabel:** `detection_history`

| Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | ID unik riwayat |
| `label_key` | `TEXT NOT NULL` | Kunci kelas asli (misal: `Leaf_Blast`) |
| `disease_name` | `TEXT NOT NULL` | Nama Bahasa Indonesia (misal: `Blas Daun`) |
| `confidence` | `REAL NOT NULL` | Nilai keyakinan (0.0 – 100.0) |
| `is_low_confidence` | `INTEGER NOT NULL` | `1` jika $< 75\%$, `0` jika $\ge 75\%$ |
| `second_label_key` | `TEXT` | Kemungkinan kelas ke-2 (berguna saat keyakinan rendah) |
| `second_confidence` | `REAL` | Persentase keyakinan kelas ke-2 |
| `image_path` | `TEXT NOT NULL` | Lokasi file gambar di folder internal aplikasi |
| `created_at` | `TEXT NOT NULL` | Timestamp ISO-8601 |

---

## 11. Rencana Pengembangan & *Timeline* (23 Nov – 15 Des 2026)

| Periode | Tahap | Target Output |
| :--- | :--- | :--- |
| **23–25 Nov 2026** | **Setup Proyek & Integrasi AI** | Inisialisasi proyek Flutter, konfigurasi izin Android (Kamera/Galeri), pemasangan `model_padi_multidomain.tflite`, pembuatan `classifier_service.dart`, dan uji inferensi pertama di HP fisik. |
| **26–29 Nov 2026** | **Fitur Kamera, Crop & Hasil** | Implementasi `image_picker` + `image_cropper` (1:1), penyusunan konten `disease_data.dart` (5 kelas), dan halaman `result_screen.dart` lengkap dengan *Confidence Threshold* 75%. |
| **30 Nov – 3 Des 2026** | **Penyimpanan Lokal & Riwayat** | Implementasi `sqflite` (`database_helper.dart`) dan `path_provider` (`image_storage_service.dart`), halaman `history_screen.dart` (lihat detail & hapus). |
| **4–7 Des 2026** | **Ensiklopedia & Polish UI/UX** | Pembuatan `home_screen.dart`, `encyclopedia_screen.dart`, `about_screen.dart`, ikon aplikasi (*launcher icon*), *splash screen*, dan perapian desain Material 3. |
| **8–11 Des 2026** | **Pengujian Lapangan & Black-Box** | Uji coba langsung dengan berbagai foto daun padi (sawah & latar polos), pencatatan tabel *Black-Box Testing* untuk Bab Pengujian Skripsi, dan perbaikan *bug*. |
| **12–15 Des 2026** | **Build Release & Finalisasi** | Build APK/AAB rilis, persiapan demo bimbingan dosen, dan (opsional) persiapan aset untuk unggah ke Google Play Store. |