# DESIGN.md — CekPadi Design System

## 1. Identitas & Karakter Produk
* **Produk:** CekPadi (Aplikasi Pendeteksi Penyakit Daun Padi Lapangan).
* **Persona Utama:** Petani padi Indonesia dan Penyuluh Pertanian Lapangan (PPL).
* **Konteks Penggunaan:** Di pematang sawah di bawah sinar matahari terik, seringkali dengan tangan kotor/berlumpur, koneksi internet nol/tidak stabil (*offline*).
* **Karakter Visual:** Fungsional, tanggap, membumi, berkontras tinggi (*outdoor-readable*), jujur tanpa gimik template AI.

---

## 2. Palet Warna (Aturan R-29: 2-3 Warna Inti + 1 Aksen)
* **Warna Dasar Netral:**
  - `surfaceBackground`: `#F7F9F6` (Putih gading alami, tidak menyilaukan mata di luar ruangan)
  - `surfaceCard`: `#FFFFFF` (Solid, batas jelas dengan border `#E2E8E0`)
  - `textPrimary`: `#142218` (Hijau-hitam arang sangat pekat, kontras tinggi > 10:1 memenuhi WCAG AAA)
  - `textSecondary`: `#4A5D50` (Abu-abu lumut pekat, tetap terbaca di bawah terik matahari)
* **Warna Inti (Brand):**
  - `primaryGreen`: `#1E5E3A` (Hijau daun padi tua yang sehat dan tegas, bukan gradasi biru/ungu default)
  - `primaryContainer`: `#E5F2E9` (Hijau muda lembut untuk kontainer fungsional)
* **Warna Aksen / Sinyal:**
  - `accentAmber`: `#D97706` (Kuning keemasan bulir padi matang untuk tombol sekunder dan peringatan penting)
* **Status Semantik (Makna Agronomi Jelas):**
  - **Sehat:** `#1E5E3A` (Hijau daun normal)
  - **Terindikasi Penyakit:** `#B91C1C` (Merah bata tegas)
  - **Perlu Foto Ulang / Ragu:** `#C2410C` (Oranye tanah)

---

## 3. Tipografi
* Menggunakan **System Sans-Serif Native** bawaan Android OS.
* **Alasan:**
  1. Menghilangkan ketergantungan jaringan runtime `google_fonts` yang sering memicu error *Failed host lookup fonts.gstatic.com* pada mode offline sawah.
  2. Rendering native 60fps tanpa jeda unduh font.
  3. Skala keterbacaan tinggi dengan bobot font teratur (Regular 400, Semi-Bold 600, Bold 700).

---

## 4. Dials Antislop (Part 3)
* **ENERGY: 1 (Calm & Utilitarian)**
  - Tampilan seperti buku panduan lapangan / instrumen kerja pertanian.
  - Bebas dari ornamen mengambang (*mesh gradients*, *glassmorphism*, atau *capsule badge* hiasan tanpa fungsi).
* **RHYTHM: 2 (Balanced)**
  - Tombol aksi utama (Kamera) mendominasi secara jelas dengan target sentuh besar ($> 56\text{px}$).
  - Pemisahan informasi terstruktur: diagnosis instan di atas, panduan tindakan di tengah, data teknis di bawah.
* **MOTION: 1 (Minimal & Fungsional)**
  - Hanya respon sentuhan alami (*ripple* / *feedback* sentuhan tombol). Tidak ada animasi loop, floating, atau denyut tanpa akhir.
