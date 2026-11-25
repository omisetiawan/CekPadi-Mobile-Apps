# 🌾 CekPadi — Aplikasi Mobile Deteksi Penyakit Daun Padi Berbasis AI (*Offline-First*)

[![Flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)
[![Model](https://img.shields.io/badge/AI%20Model-EfficientNet--B0%20(Float16)-FF6F00?logo=tensorflow)](https://tensorflow.org)
[![Architecture](https://img.shields.io/badge/System-100%25%20Offline--First-2E7D32)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)]()

> **CekPadi** adalah aplikasi mobile cerdas berbasis *Computer Vision* dan *On-Device AI* untuk membantu petani, praktisi pertanian, serta penyuluh lapangan mengidentifikasi 4 penyakit utama daun padi dan kondisi daun sehat secara cepat, akurat, dan **100% tanpa memerlukan koneksi internet**.

---

## 📌 Informasi Tugas Akhir (Skripsi)

| Atribut | Keterangan |
| :--- | :--- |
| **Judul Skripsi** | **Perbandingan Transfer Learning Arsitektur EfficientNet-B0 dan MobileNetV2 untuk Deteksi Penyakit Daun Padi Berbasis Citra pada Aplikasi Mobile Offline** |
| **Pengembang** | **Romi Setiawan** |
| **NIM** | **2305083** |
| **Program Studi** | D4 Rekayasa Perangkat Lunak |
| **Institusi** | Politeknik Negeri Indramayu (POLINDRA) |
| **Versi Aplikasi** | `1.0.0` |

---

## 🌾 Latar Belakang & Masalah

Keterlambatan identifikasi penyakit tanaman padi di lapangan sering menyebabkan gagal panen dan penurunan produktivitas pertanian secara drastis. Di sisi lain:
1. **Kendala Sinyal di Sawah:** Kawasan persawahan di pedesaan umumnya memiliki koneksi internet yang lemah, tidak stabil, atau bahkan *blind spot*.
2. **Keterbatasan Aplikasi Berbasis Cloud:** Aplikasi yang mengandalkan server/cloud API membutuhkan kuota dan sering gagal memproses gambar saat berada di tengah sawah.
3. **Kemiripan Gejala Visual:** Gejala awal penyakit seperti *Bercak Cokelat* dan *Blas Daun* memiliki kemiripan bercak yang sulit dibedakan oleh mata petani pemula tanpa bantuan alat panduan.

**Solusi CekPadi:** Mengimplementasikan model *Deep Learning* terkuantisasi (TensorFlow Lite Float16) yang berjalan sepenuhnya di perangkat seluler (*on-device inference*), sehingga proses deteksi berlangsung instan, privat, dan mandiri tanpa server backend.

---

## 🎯 5 Kelas Diagnosis yang Didukung

Aplikasi mampu mengklasifikasikan 5 kondisi daun padi:

| # | Nama Penyakit | Nama Ilmiah / Patogen | Golongan |
|:-:|:---|:---|:---:|
| 1 | **Hawar Daun Bakteri (Kresek)** | *Xanthomonas oryzae pv. oryzae* | Bakteri |
| 2 | **Bercak Cokelat** | *Bipolaris oryzae (Helminthosporium oryzae)* | Jamur |
| 3 | **Blas Daun** | *Magnaporthe oryzae (Pyricularia oryzae)* | Jamur |
| 4 | **Penyakit Tungro** | *Rice tungro bacilliform virus (RTBV) & RTSV* | Virus (Vektor Wereng Hijau) |
| 5 | **Daun Sehat** | *Oryza sativa (Kondisi Normal)* | Sehat |

---

## 🔬 Perbandingan Ilmiah 2 Metode (Model AI)

Penelitian ini membandingkan dua arsitektur *Transfer Learning* berbasis *Convolutional Neural Network* (CNN) yang dilatih menggunakan dataset *multi-domain* (5.000 citra gabungan foto sawah lapangan dan latar polos, protokol split *Train/Val/Test* terpisah 3 *random seeds*):

| Parameter Evaluasi | MobileNetV2 (Pembanding) | EfficientNet-B0 (Model Utama Terpasang) | Catatan / Keunggulan |
| :--- | :---: | :---: | :--- |
| **Akurasi Test (Rata-rata)** | 92,68 ± 0,33% | **96,20 ± 0,33%** | EfficientNet-B0 unggul **+3,52%** |
| **Macro F1-Score** | 92,70 ± 0,31% | **96,18 ± 0,33%** | Pembedaan antar-kelas lebih seimbang |
| **Akurasi Model Terpilih (Seed 42)** | 92,91% | **95,97%** | Model yang diekspor ke TFLite |
| **Format & Kuantisasi** | TFLite Float16 | **TFLite Float16** | 100% konsisten dengan model Keras |
| **Ukuran File Model** | 4,52 MB | **8,15 MB** | Sangat ringan untuk penyimpanan HP |
| **Waktu Inferensi di HP Fisik** | ~256 ms | **~410 - 560 ms** | Di bawah 0,6 detik (sangat responsif) |
| **Kalibrasi Suhu ($T$)** | $T = 0,5826$ | **$T = 0,5534$** | Mengoreksi *overconfidence* model |

> **Kesimpulan:** **EfficientNet-B0** dipilih sebagai model utama aplikasi CekPadi karena menghasilkan akurasi yang lebih tinggi dan generalisasi visual yang lebih tajam pada gejala kompleks (seperti membedakan fase kresek pada daun mengering), dengan waktu inferensi yang tetap berada jauh di bawah ambang batas toleransi interaksi pengguna ($< 1$ detik).

---

## ✨ Fitur-Fitur Utama Aplikasi

### 1. 📷 Pemindaian Daun & Rasio Terkunci 1:1
* Pengguna dapat mengambil foto langsung menggunakan kamera HP atau memilih foto dari galeri.
* Dilengkapi pemotong citra persegi (*Square Cropping 1:1*) agar pengguna memfokuskan bingkai pada helai daun bergejala, sekaligus mencegah distorsi citra (*stretching*) saat di-*resize* ke input tensor $224 \times 224$.

### 2. ⚡ Inferensi Instan On-Device & Rincian Waktu
* Inferensi dijalankan secara lokal di C++ runtime TFLite menggunakan multi-threading.
* Menampilkan rincian waktu pemrosesan secara transparan:
  - **Waktu Inferensi Murni ($T_{\text{inferensi}}$):** Durasi komputasi model AI.
  - **Waktu Preprocessing ($T_{\text{prep}}$):** Durasi decode gambar, normalisasi rotasi EXIF, dan resizing.

### 3. 🛡️ Pengaman Ketidakpastian (*Confidence Threshold 75%*)
* **Keyakinan $\ge 75\%$:** Diagnosis utama ditampilkan tegas beserta status dan panduan penanganan lengkap.
* **Keyakinan $< 75\%$:** Menampilkan kartu peringatan **"Tingkat Keyakinan Kurang dari 75% / Perlu Foto Ulang"**, menampilkan **2 kemungkinan penyakit teratas (Top-2)** beserta persentasenya, dan tombol langsung untuk mengambil foto ulang lebih dekat.

### 4. 🌡️ Kalibrasi Suhu (*Temperature Scaling*)
* Menerapkan fungsi kalibrasi probabilitas $q_i = \frac{p_i^{1/T}}{\sum_j p_j^{1/T}}$ dengan parameter $T = 0,5534$ untuk menurunkan skor ekstrem ($99,9\% - 100\%$) dan menyelaraskan nilai kepercayaan model dengan akurasi empiris sebenarnya.

### 5. 📚 Ensiklopedia Agronomi Resmi Offline
* Memuat katalog 5 kelas daun padi berdasarkan rekomendasi Balai Besar Penelitian Tanaman Padi (BBPadi / BRIN) dan Kementan RI:
  - Ciri-ciri visual gejala lapangan.
  - Kondisi lingkungan yang memicu serangan penyakit.
  - Langkah pencegahan dini dan pemilihan varietas tahan.
  - Pengendalian teknis & agens hayati/biologis.
  - Rekomendasi bahan aktif kimiawi (fungisida/bakterisida) secara bijak.

### 6. 💾 Riwayat Pemeriksaan Lokal (SQLite)
* Setiap hasil pemeriksaan otomatis tersimpan ke database lokal SQLite (`cekpadi.db`).
* Menggunakan arsitektur reaktif `ValueNotifier` sehingga penambahan atau penghapusan data otomatis memperbarui tampilan tanpa perlu *pull-to-refresh*.
* File foto hasil crop disimpan di direktori internal aplikasi agar tidak mengotori galeri foto pribadi pengguna.

### 7. 🎨 Desain Aksesibilitas Sawah (*Anti-slop / Outdoor-Readable*)
* **Kontras Sangat Tinggi (WCAG AAA > 10:1):** Teks utama arang pekat (`#142218`) di atas latar putih gading alami (`#F7F9F6`), mudah dibaca di bawah terik sinar matahari sawah.
* **Native System Typography:** Menggunakan sistem font bawaan OS untuk menghilangkan ketergantungan jaringan runtime `google_fonts` yang rawan error saat offline.
* **Target Sentuh Besar ($> 56\text{px}$):** Memudahkan navigasi bagi petani dengan satu tangan di pematang sawah.

---

## 🏗️ Alur Pemrosesan Citra (*Preprocessing Pipeline*)

```
[Foto Kamera / Galeri]
         │
         ▼
[ImageCropper: Crop Rasio Persegi 1:1]
         │
         ▼
[img.decodeImage: Baca Byte Citra]
         │
         ▼
[img.bakeOrientation: Koreksi Rotasi EXIF Kamera]
         │
         ▼
[img.copyResize: Resize ke 224 x 224 (Interpolasi Linear)]
         │
         ▼
[Tensor Input: Shape (1, 224, 224, 3) Float32 | Rentang 0.0 - 255.0]
         │
         ▼
[TFLite Interpreter: EfficientNet-B0 (Normalisasi Tertanam di Model)]
         │
         ▼
[Output Softmax Mentah: 5 Kelas]
         │
         ▼
[Temperature Scaling: Softmax(Log(P) / 0.5534)]
         │
         ▼
[Logika Ambang Batas 75% -> Halaman Hasil Diagnosis & Rekomendasi]
```

---

## 📂 Struktur Direktori Proyek

```text
cekpadi/
├── android/                   # Konfigurasi native Android (Gradle, Manifest, UCropActivity)
├── assets/
│   ├── icon/                  # Ikon aplikasi CekPadi
│   └── models/
│       ├── labels_multidomain.txt      # Daftar 5 label kelas
│       └── model_padi_multidomain.tflite # Model utama TFLite Float16 (8,15 MB)
├── lib/
│   ├── data/
│   │   ├── database_helper.dart        # Database SQLite & ValueNotifier riwayat
│   │   └── disease_data.dart           # Basis data referensi gejala & penanganan resmi
│   ├── models/
│   │   ├── detection_record.dart       # Model entitas riwayat deteksi
│   │   └── disease_info.dart           # Model entitas informasi penyakit
│   ├── screens/
│   │   ├── about_screen.dart           # Layar Informasi Skripsi & Model AI
│   │   ├── encyclopedia_screen.dart    # Layar Katalog & Buku Saku Agronomi
│   │   ├── history_screen.dart         # Layar Riwayat Pemeriksaan Lokal
│   │   ├── home_screen.dart            # Layar Beranda & Tombol Utama Pemindaian
│   │   ├── main_navigation.dart        # Navigasi Bottom Bar & Bottom Sheet Pemindaian
│   │   └── result_screen.dart          # Layar Hasil Diagnosis, Latensi, & Panduan
│   ├── services/
│   │   ├── classifier_service.dart     # Service TFLite, Preprocessing, & Kalibrasi Suhu
│   │   └── image_storage_service.dart  # Service penyimpanan file foto lokal
│   ├── theme/
│   │   └── app_theme.dart              # Desain sistem, palet warna, & tema WCAG AAA
│   ├── utils/
│   │   └── image_helper.dart           # Helper pemotongan citra 1:1 (ImagePicker & UCrop)
│   └── main.dart                       # Entry point aplikasi Flutter
├── test/
│   ├── disease_data_test.dart          # Unit test: 5 label, database SQLite, & kalibrasi
│   └── widget_test.dart                # Widget test: Ensiklopedia & Layar Tentang
├── pubspec.yaml                        # Dependensi paket & deklarasi aset
└── README.md                           # Dokumentasi lengkap proyek
```

---

## 🚀 Panduan Memulai (*Getting Started*)

### 1. Prasyarat Sistem
* **Flutter SDK:** Versi `^3.41.0` (kompatibel dengan Dart `>=3.11.0 <4.0.0`).
* **Android SDK:** Platform SDK 35 (Android 15) atau SDK 34 dengan Android Build Tools 35/36.
* **Perangkat Pengujian:** HP Android fisik dengan kamera (disarankan mengaktifkan *Developer Options* & *USB Debugging*).

### 2. Instalasi Dependensi
Klon repositori ini atau buka direktori proyek, lalu jalankan:
```powershell
flutter pub get
```

### 3. Verifikasi Analisis & Testing
Pastikan seluruh unit test dan lint analysis dalam kondisi hijau:
```powershell
flutter test
flutter analyze
```

### 4. Menjalankan Aplikasi di HP Android
Hubungkan HP Android ke komputer menggunakan kabel data USB, lalu jalankan:
```powershell
flutter run
```

### 5. Membangun File Installer APK
Untuk menghasilkan file installer APK siap pasang:
* **Mode Debug APK:**
  ```powershell
  flutter build apk --debug
  ```
  *File APK akan berada di:* `build/app/outputs/flutter-apk/app-debug.apk`
* **Mode Release APK:**
  ```powershell
  flutter build apk --release
  ```

---

## 🧪 Hasil Pengujian Unit & Widget Test

Proyek ini telah dilengkapi serangkaian pengujian otomatis (`test/`):
- ✅ **Validasi Label Multidomain:** Memastikan tepat 5 kelas dan terhubung ke database agronomi.
- ✅ **Validasi Kelas Daun Sehat:** Memastikan kondisi sehat memiliki atribut `isHealthy = true`.
- ✅ **Serialisasi SQLite:** Memastikan konversi objek `DetectionRecord` ke/dari Map konsisten.
- ✅ **Ambang Batas Keyakinan:** Memastikan batas ambang $75\%$ dan input $224 \times 224$ valid.
- ✅ **Uji Kalibrasi Suhu:** Memastikan rumus $T$-scaling menormalkan probabilitas menjadi total $1,0$.
- ✅ **Pengujian Tampilan Ensiklopedia:** Memastikan 5 penyakit muncul lengkap di katalog.
- ✅ **Pengujian Tampilan Layar Tentang:** Memastikan informasi skripsi dan arsitektur model AI tampil tepat.

---

## 📜 Lisensi & Atribusi

* **Pengembang:** Romi Setiawan (Politeknik Negeri Indramayu).
* **Basis Data Agronomi:** Merujuk pada panduan resmi Balai Besar Penelitian Tanaman Padi (BBPadi / Balitbangtan) dan Badan Riset dan Inovasi Nasional (BRIN).
* **Lisensi Kode:** Terbuka untuk keperluan akademis dan penelitian di bawah lisensi [MIT License](LICENSE).
