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
    // Berlangganan ke sinyal perubahan database agar tampilan selalu update otomatis
    DatabaseHelper.historyChangeNotifier.addListener(_loadDashboardData);
    _loadDashboardData();
  }

  @override
  void dispose() {
    DatabaseHelper.historyChangeNotifier.removeListener(_loadDashboardData);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
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

  /// Alur Deteksi: Ambil Foto -> Crop 1:1 -> AI On-Device -> Simpan -> Buka Hasil
  Future<void> _startDetection(ImageSource source) async {
    final File? croppedFile = await ImageHelper.pickAndCropImage(
      context: context,
      source: source,
    );

    if (croppedFile == null || !mounted) return;

    // Tampilkan Dialog Loading Fungsional
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text(
                  'Menganalisis Daun...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Memproses citra di perangkat',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
      final savedImagePath = await ImageStorageService.saveImage(croppedFile);

      if (mounted) {
        Navigator.pop(context); // Tutup dialog loading

        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              classifierResult: result,
              imagePath: savedImagePath,
              isFromScan: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menganalisis citra: $e'),
            backgroundColor: AppTheme.statusDisease,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CekPadi'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_pin_outlined, size: 14, color: AppTheme.primaryGreen),
                SizedBox(width: 4),
                Text(
                  'Mode Lapangan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
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
              // 1. Kartu Aksi Utama Pemeriksaan (Desain Khusus Lapangan)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pemeriksaan Gejala Daun',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Arahkan kamera ke helai daun yang berbercak untuk mendiagnosis penyakit dan panduan penanganannya.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Kamera Utama (Besar, Mudah ditekan di sawah)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 24),
                        label: const Text('Foto Daun Padi (Kamera)'),
                        onPressed: () => _startDetection(ImageSource.camera),
                      ),
                      const SizedBox(height: 10),

                      // Tombol Galeri Sekunder
                      OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined, size: 20, color: AppTheme.textSecondary),
                        label: const Text('Pilih dari Galeri Foto'),
                        onPressed: () => _startDetection(ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Petunjuk Pemotretan Lapangan
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.crop_free, size: 18, color: AppTheme.primaryGreen),
                          SizedBox(width: 8),
                          Text(
                            'Panduan Mengambil Foto',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildGuideRow(
                        number: '1',
                        title: 'Satu helai daun bergejala',
                        desc: 'Posisikan bingkai kotak (1:1) tepat pada bercak daun utama.',
                      ),
                      const SizedBox(height: 10),
                      _buildGuideRow(
                        number: '2',
                        title: 'Jarak 10 sampai 15 cm',
                        desc: 'Dekatkan kamera agar detail warna dan tekstur bercak tajam.',
                      ),
                      const SizedBox(height: 10),
                      _buildGuideRow(
                        number: '3',
                        title: 'Pencahayaan terang alami',
                        desc: 'Hindari bayangan gelap tangan atau foto daun yang bergoyang.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Riwayat Terakhir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pemeriksaan Terakhir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Total tersimpan: $_totalHistory catatan',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  if (_totalHistory > 0)
                    TextButton(
                      onPressed: () => widget.onNavigateTab(1),
                      child: const Text('Buka Riwayat'),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                )
              else if (_recentRecords.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 36, color: AppTheme.textSecondary),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada catatan pemeriksaan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hasil pemeriksaan daun yang kamu lakukan akan tersimpan otomatis di sini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final record = _recentRecords[index];
                    return _buildRecordTile(record);
                  },
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideRow({
    required String number,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTile(DetectionRecord record) {
    final bool isHealthy = record.labelKey == 'Healthy';
    final Color statusColor = record.isLowConfidence
        ? AppTheme.statusWarning
        : (isHealthy ? AppTheme.statusHealthy : AppTheme.statusDisease);

    final String statusLabel = record.isLowConfidence
        ? 'Perlu Foto Ulang'
        : (isHealthy ? 'Kondisi Sehat' : 'Terindikasi');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                existingRecord: record,
                imagePath: record.imagePath,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Image.file(
                    File(record.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.primaryContainer,
                      child: const Icon(Icons.broken_image, size: 24, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.diseaseName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(record.createdAt),
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${record.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
