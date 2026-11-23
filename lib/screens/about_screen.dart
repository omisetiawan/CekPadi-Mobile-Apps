import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Logo & Versi
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryGreen, width: 2),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 48,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CekPadi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versi 1.0.0 (MVP Skripsi)',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Informasi Skripsi & Pengembang
            _buildInfoCard(
              title: 'Informasi Tugas Akhir (Skripsi)',
              icon: Icons.school_rounded,
              children: [
                _buildRowItem('Pengembang', 'Romi Setiawan'),
                _buildRowItem('Program Studi', 'D4 Rekayasa Perangkat Lunak'),
                _buildRowItem('Institusi', 'Politeknik Negeri Indramayu'),
                _buildRowItem(
                  'Judul Skripsi',
                  'Klasifikasi Penyakit Daun Padi Berbasis Citra Menggunakan Transfer Learning MobileNetV2 pada Aplikasi Mobile dengan Rekomendasi Penanganannya',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Spesifikasi Model AI (On-Device)
            _buildInfoCard(
              title: 'Spesifikasi Model AI',
              icon: Icons.memory_rounded,
              children: [
                _buildRowItem('Arsitektur Model', 'MobileNetV2 (Transfer Learning)'),
                _buildRowItem('Format File', 'TensorFlow Lite (.tflite)'),
                _buildRowItem('Ukuran Model', '2,55 MB (On-Device / 100% Offline)'),
                _buildRowItem('Input Tensor', '1 x 224 x 224 x 3 (Float32)'),
                _buildRowItem('Akurasi Validasi', '91,36% (F1-Score: 91,36%)'),
                _buildRowItem('Dataset Evaluasi', '5.000 citra multi-domain (lapangan & latar polos)'),
                _buildRowItem('Ambang Batas', '75% Confidence Threshold'),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Batasan Sistem (PRD Bab 4)
            _buildInfoCard(
              title: 'Batasan Sistem (Out of Scope)',
              icon: Icons.rule_folder_outlined,
              children: [
                _buildBullet('Hanya mendeteksi 4 jenis penyakit daun padi utama (Hawar Daun Bakteri/Kresek, Bercak Cokelat, Blas Daun, Tungro) dan kondisi Daun Sehat.'),
                _buildBullet('Bukan detektor hama serangga (ulat, wereng, atau belalang), melainkan gejala bercak/kerusakan pada helai daun padi.'),
                _buildBullet('Tidak mencakup penyakit di luar 5 kelas (misal: hawar pelepah, kerdil rumput, atau kerusakan bulir).'),
                _buildBullet('100% offline-first: seluruh pemrosesan dan data riwayat tersimpan di memori lokal HP tanpa mengirim foto ke cloud/server.'),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Disclaimer
            Card(
              color: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.accentAmber, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.warningOrange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pernyataan Penyangkalan (Disclaimer)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aplikasi ini dirancang sebagai alat bantu pendeteksi dini dan edukasi bagi petani maupun penyuluh pertanian. Hasil diagnosis tidak menggantikan inspeksi langsung oleh ahli proteksi tanaman resmi bila terjadi wabah penyakit skala luas.',
                      style: TextStyle(fontSize: 11.5, height: 1.4, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
