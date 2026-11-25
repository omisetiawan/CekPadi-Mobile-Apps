import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../data/disease_data.dart';
import '../models/detection_record.dart';
import '../models/disease_info.dart';
import '../services/classifier_service.dart';
import '../services/image_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';
import 'package:image_picker/image_picker.dart';

class ResultScreen extends StatefulWidget {
  final ClassifierResult? classifierResult;
  final DetectionRecord? existingRecord;
  final String imagePath;
  final bool isFromScan;

  const ResultScreen({
    super.key,
    this.classifierResult,
    this.existingRecord,
    required this.imagePath,
    this.isFromScan = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int? _savedRecordId;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _savedRecordId = widget.existingRecord!.id;
    } else if (widget.isFromScan && widget.classifierResult != null) {
      _saveDetectionToHistory();
    }
  }

  /// Otomatis simpan hasil scan ke database SQLite
  Future<void> _saveDetectionToHistory() async {
    try {
      final res = widget.classifierResult!;
      final newRecord = DetectionRecord(
        labelKey: res.labelKey,
        diseaseName: res.diseaseInfo.nameId,
        confidence: res.confidence,
        isLowConfidence: res.isLowConfidence,
        secondLabelKey: res.secondLabelKey,
        secondConfidence: res.secondConfidence,
        imagePath: widget.imagePath,
        createdAt: DateTime.now(),
      );

      final id = await DatabaseHelper.instance.insertRecord(newRecord);
      if (mounted) {
        setState(() {
          _savedRecordId = id;
        });
      }
    } catch (e) {
      debugPrint('Gagal menyimpan otomatis ke riwayat: $e');
    }
  }

  /// Hapus dari riwayat
  Future<void> _deleteFromHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan Ini?'),
        content: const Text(
          'Catatan diagnosis ini beserta file fotonya akan dihapus permanen dari memori internal HP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusDisease,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (_savedRecordId != null) {
        await DatabaseHelper.instance.deleteRecord(_savedRecordId!);
      }
      await ImageStorageService.deleteImage(widget.imagePath);
      setState(() {
        _isDeleted = true;
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Ambil foto ulang
  Future<void> _retakePhoto(ImageSource source) async {
    final file = await ImageHelper.pickAndCropImage(context: context, source: source);
    if (file == null || !mounted) return;

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
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final classifier = ClassifierService();
      await classifier.initialize();
      final result = await classifier.classifyImage(file);
      final persistentPath = await ImageStorageService.saveImage(file);

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              classifierResult: result,
              imagePath: persistentPath,
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
            content: Text('Gagal menganalisis foto: $e'),
            backgroundColor: AppTheme.statusDisease,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleted) {
      return const Scaffold(
        body: Center(child: Text('Data pemeriksaan telah dihapus.')),
      );
    }

    final String labelKey = widget.classifierResult?.labelKey ??
        widget.existingRecord?.labelKey ??
        'Healthy';
    final double confidence = widget.classifierResult?.confidence ??
        widget.existingRecord?.confidence ??
        0.0;
    final bool isLowConfidence = widget.classifierResult?.isLowConfidence ??
        widget.existingRecord?.isLowConfidence ??
        false;
    final DiseaseInfo diseaseInfo = DiseaseData.getInfo(labelKey);
    final String? secondLabelKey = widget.classifierResult?.secondLabelKey ??
        widget.existingRecord?.secondLabelKey;
    final double? secondConfidence = widget.classifierResult?.secondConfidence ??
        widget.existingRecord?.secondConfidence;
    final int? inferenceTime = widget.classifierResult?.inferenceTimeMs;
    final int? prepTime = widget.classifierResult?.preprocessingTimeMs;

    final Color statusColor = isLowConfidence
        ? AppTheme.statusWarning
        : (diseaseInfo.isHealthy ? AppTheme.statusHealthy : AppTheme.statusDisease);

    final String statusBadgeText = isLowConfidence
        ? 'Perlu Foto Ulang'
        : (diseaseInfo.isHealthy ? 'Kondisi Sehat' : 'Terindikasi Penyakit');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Diagnosis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.statusDisease),
            tooltip: 'Hapus dari riwayat',
            onPressed: _deleteFromHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Foto Daun Hasil Crop (Rasio Terkunci 1:1)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primaryContainer,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Banner Peringatan Jika Keyakinan < 75%
            if (isLowConfidence) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.statusWarning.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: AppTheme.statusWarning, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tingkat Keyakinan Kurang dari 75%',
                            style: TextStyle(
                              color: AppTheme.statusWarning,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bercak daun terdeteksi belum cukup jelas. Dianjurkan mengambil foto lebih dekat (10-15 cm) ke helai daun yang bergejala agar diagnosis lebih pasti.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.statusWarning,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 46),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Foto Ulang', style: TextStyle(fontSize: 14)),
                            onPressed: () => _retakePhoto(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 46),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Pilih Galeri', style: TextStyle(fontSize: 14)),
                            onPressed: () => _retakePhoto(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 3. Kartu Hasil Diagnosis Utama
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusBadgeText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (inferenceTime != null)
                          Text(
                            prepTime != null
                                ? 'Inferensi: ${inferenceTime}ms (Prep: ${prepTime}ms)'
                                : 'Waktu analisis: ${inferenceTime}ms',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      diseaseInfo.nameId,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      diseaseInfo.scientificName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bar Tingkat Keyakinan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tingkat Keyakinan Model:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '${confidence.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (confidence / 100.0).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE5E7EB),
                        color: statusColor,
                      ),
                    ),

                    // Top 2 Kemungkinan (Jika keyakinan < 75%)
                    if (isLowConfidence && secondLabelKey != null) ...[
                      const SizedBox(height: 14),
                      const Divider(color: AppTheme.borderMuted),
                      const SizedBox(height: 8),
                      const Text(
                        'Kemungkinan Teratas:',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      _buildProbabilityItem(1, diseaseInfo.nameId, confidence, statusColor),
                      const SizedBox(height: 4),
                      _buildProbabilityItem(
                        2,
                        DiseaseData.getInfo(secondLabelKey).nameId,
                        secondConfidence ?? 0.0,
                        AppTheme.textSecondary,
                      ),
                    ],

                    if (widget.existingRecord != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Diperiksa pada ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(widget.existingRecord!.createdAt)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Panduan Tindakan Cepat Lapangan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.health_and_safety_outlined, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Langkah Pengendalian Lapangan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pengendalian Teknis & Hayati
                    _buildSectionHeader('Tindakan Teknis & Biologis', Icons.eco_outlined),
                    ...diseaseInfo.technicalControl.map((item) => _buildBulletPoint(item)),
                    const SizedBox(height: 14),

                    // Bahan Aktif Kimiawi
                    if (diseaseInfo.chemicalControl.isNotEmpty) ...[
                      _buildSectionHeader('Rekomendasi Bahan Aktif / Kimiawi', Icons.science_outlined),
                      ...diseaseInfo.chemicalControl.map((item) => _buildBulletPoint(item)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Gejala & Ciri Lapangan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search_outlined, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Karakteristik & Gejala Visual',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      diseaseInfo.shortDescription,
                      style: const TextStyle(fontSize: 13, height: 1.45, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 14),

                    _buildSectionHeader('Ciri Gejala pada Helai Daun', Icons.visibility_outlined),
                    ...diseaseInfo.symptoms.map((item) => _buildBulletPoint(item)),
                    const SizedBox(height: 14),

                    _buildSectionHeader('Faktor Pemicu Lingkungan', Icons.thermostat_outlined),
                    ...diseaseInfo.favorableConditions.map((item) => _buildBulletPoint(item)),
                    const SizedBox(height: 14),

                    _buildSectionHeader('Pencegahan untuk Musim Berikutnya', Icons.shield_outlined),
                    ...diseaseInfo.preventionSteps.map((item) => _buildBulletPoint(item)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Evaluasi Output Model (Data 5 Kelas untuk Sidang Skripsi)
            if (widget.classifierResult != null) ...[
              Card(
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Rincian Probabilitas 5 Kelas (Skripsi)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Distribusi nilai probabilitas softmax model MobileNetV2',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: widget.classifierResult!.allProbabilities.entries.map((entry) {
                            final info = DiseaseData.getInfo(entry.key);
                            final bool isTop = entry.key == widget.classifierResult!.labelKey;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      info.nameId,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                                        color: isTop ? AppTheme.primaryGreen : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: entry.value / 100.0,
                                        minHeight: 6,
                                        backgroundColor: const Color(0xFFE5E7EB),
                                        color: isTop ? AppTheme.primaryGreen : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      '${entry.value}%',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                                        color: isTop ? AppTheme.primaryGreen : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityItem(int rank, String name, double conf, Color color) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ),
        Text(
          '${conf.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
