import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../models/detection_record.dart';
import '../services/classifier_service.dart';
import '../services/image_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalHistory = 0;
  List<DetectionRecord> _recentRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final count = await DatabaseHelper.instance.getRecordCount();
    final recents = await DatabaseHelper.instance.getRecentRecords(limit: 3);

    if (mounted) {
      setState(() {
        _totalHistory = count;
        _recentRecords = recents;
        _isLoading = false;
      });
    }
  }

  /// Proses Deteksi: Ambil Foto -> Crop 1:1 -> AI TFLite -> Simpan -> Buka Hasil
  Future<void> _startDetection(ImageSource source) async {
    final File? croppedFile = await ImageHelper.pickAndCropImage(
      context: context,
      source: source,
    );

    if (croppedFile == null || !mounted) return;

    // Tampilkan Dialog Loading Inferensi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text(
                  'Menganalisis Daun Padi...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  'Menggunakan AI On-Device',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final classifier = ClassifierService();
      await classifier.initialize();
      final result = await classifier.classifyImage(croppedFile);

      // Simpan ke direktori dokumen lokal HP
      final savedImagePath = await ImageStorageService.saveImage(croppedFile);

      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog

        final bool? needRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              classifierResult: result,
              imagePath: savedImagePath,
              isFromScan: true,
            ),
          ),
        );

        if (needRefresh == true || mounted) {
          _loadDashboardData();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menjalankan inferensi: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.eco, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text('CekPadi', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan data',
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sambutan & Banner Selamat Datang
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryDarkGreen, AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.offline_bolt, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '100% Offline AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total Scan: $_totalHistory',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Deteksi Cepat Penyakit\nDaun Tanaman Padi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dapatkan hasil diagnosis akurat dan rekomendasi penanganan instan langsung di sawah tanpa kuota internet.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Tombol Aksi Utama (Kamera & Galeri)
              const Text(
                'Mulai Pemeriksaan Daun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Tombol Kamera
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _startDetection(ImageSource.camera),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.primaryLightGreen,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 30,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Ambil Foto',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Gunakan Kamera HP',
                                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Galeri
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _startDetection(ImageSource.gallery),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFFFF8E1),
                                child: const Icon(
                                  Icons.photo_library_rounded,
                                  size: 30,
                                  color: AppTheme.accentAmber,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Pilih Galeri',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ambil dari Album',
                                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Tips Pengambilan Foto Akurat (PRD F1)
              Card(
                color: const Color(0xFFF1F8E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb_outline, color: AppTheme.primaryDarkGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tips Pemindaian Akurat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTipItem('Fokuskan bingkai crop (1:1) tepat pada 1 helai daun yang bergejala.'),
                      _buildTipItem('Pastikan pencahayaan terang dan foto tidak goyang/buram.'),
                      _buildTipItem('Hindari mengambil terlalu banyak daun sekaligus dalam satu bingkai.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Riwayat Terakhir (3 Catatan Terakhir)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Terakhir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(1), // Pindah ke Tab Riwayat
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_recentRecords.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'Belum ada riwayat pemeriksaan',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentRecords.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = _recentRecords[index];
                    return _buildHistoryItem(record);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
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

  Widget _buildHistoryItem(DetectionRecord record) {
    final bool isHealthy = record.labelKey == 'Healthy';
    final Color badgeColor = record.isLowConfidence
        ? AppTheme.warningOrange
        : (isHealthy ? AppTheme.primaryGreen : AppTheme.dangerRed);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Image.file(
              File(record.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
              ),
            ),
          ),
        ),
        title: Text(
          record.diseaseName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(record.createdAt),
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${record.confidence.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: badgeColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              record.isLowConfidence
                  ? 'Keyakinan Rendah'
                  : (isHealthy ? 'Sehat' : 'Penyakit'),
              style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        onTap: () async {
          final res = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                existingRecord: record,
                imagePath: record.imagePath,
              ),
            ),
          );
          if (res == true && mounted) {
            _loadDashboardData();
          }
        },
      ),
    );
  }
}
