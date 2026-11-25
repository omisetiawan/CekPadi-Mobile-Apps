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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.primaryGreen, width: 2),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 44,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CekPadi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
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
                  'Perbandingan Transfer Learning Arsitektur EfficientNet-B0 dan MobileNetV2 untuk Deteksi Penyakit Daun Padi Berbasis Citra pada Aplikasi Mobile Offline',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Spesifikasi Model AI (On-Device)
            _buildInfoCard(
              title: 'Spesifikasi Model AI',
              icon: Icons.memory_rounded,
              children: [
                _buildRowItem('Model Utama Terpasang', 'EfficientNet-B0 (Transfer Learning)'),
                _buildRowItem('Metode Pembanding', 'MobileNetV2 (Transfer Learning)'),
                _buildRowItem('Format File', 'TensorFlow Lite (.tflite, Float16)'),
                _buildRowItem('Ukuran Model', '8,15 MB (On-Device / 100% Offline)'),
                _buildRowItem('Input Tensor', '1 x 224 x 224 x 3 (Float32)'),
                _buildRowItem('Akurasi Test', '96,20% (EfficientNet-B0) vs 92,68% (MobileNetV2)'),
                _buildRowItem('Kalibrasi Kepercayaan', 'Temperature Scaling (T = 0,5534)'),
                _buildRowItem('Ambang Batas', '75% Confidence Threshold'),
              ],
            ),
            const SizedBox(height: 14),

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
            const SizedBox(height: 14),

            // 4. Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Amber tint lembut
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentAmber, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppTheme.accentAmber, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pernyataan Penyangkalan (Disclaimer)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aplikasi ini dirancang sebagai alat bantu pendeteksi dini dan edukasi bagi petani maupun penyuluh pertanian. Hasil diagnosis tidak menggantikan inspeksi langsung oleh ahli proteksi tanaman resmi bila terjadi wabah penyakit skala luas.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderMuted, width: 1.2),
      ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.38,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
