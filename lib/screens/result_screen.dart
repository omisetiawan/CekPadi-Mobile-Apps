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
        title: const Text('Hapus Riwayat?'),
        content: const Text(
          'Catatan pemeriksaan ini beserta file gambarnya akan dihapus permanen dari memori HP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemeriksaan berhasil dihapus.')),
        );
        Navigator.pop(context, true); // true = refresh riwayat
      }
    }
  }

  /// Ambil foto ulang
  Future<void> _retakePhoto(ImageSource source) async {
    final file = await ImageHelper.pickAndCropImage(context: context, source: source);
    if (file == null || !mounted) return;

    // Tampilkan loading modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Mendiagnosis daun padi...', style: TextStyle(fontWeight: FontWeight.w600)),
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
        // Buka layar hasil baru menggantikan yang lama
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
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menganalisis foto: $e')),
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

    final Color statusColor = isLowConfidence
        ? AppTheme.warningOrange
        : (diseaseInfo.isHealthy ? AppTheme.primaryGreen : AppTheme.dangerRed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Diagnosis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed),
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
            // 1. Tampilan Foto Daun Hasil Crop (Rasio 1:1)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Banner Peringatan Keyakinan Rendah (< 75%)
            if (isLowConfidence) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange),
                        SizedBox(width: 8),
                        Text(
                          'Keyakinan Rendah (< 75%)',
                          style: TextStyle(
                            color: AppTheme.warningOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Model mendeteksi pola gejala dengan tingkat kepastian di bawah ambang batas validasi. Foto mungkin terlalu jauh, kurang fokus pada bercak, atau pencahayaan kurang merata.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Foto Ulang Kamera'),
                            onPressed: () => _retakePhoto(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.warningOrange,
                              side: const BorderSide(color: AppTheme.warningOrange),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Pilih Galeri'),
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLowConfidence
                                    ? Icons.help_outline
                                    : (diseaseInfo.isHealthy
                                        ? Icons.check_circle_outline
                                        : Icons.coronavirus_outlined),
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isLowConfidence
                                    ? 'Perlu Foto Ulang'
                                    : (diseaseInfo.isHealthy ? 'Kondisi Sehat' : 'Terindikasi Penyakit'),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (inferenceTime != null)
                          Text(
                            'Inferensi: ${inferenceTime}ms',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      diseaseInfo.nameId,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      diseaseInfo.scientificName,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress bar keyakinan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tingkat Keyakinan:',
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
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (confidence / 100.0).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: statusColor,
                      ),
                    ),

                    // Top 2 Kemungkinan (jika keyakinan rendah)
                    if (isLowConfidence && secondLabelKey != null) ...[
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Kemungkinan Teratas:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      _buildProbabilityRow(
                        1,
                        diseaseInfo.nameId,
                        confidence,
                        statusColor,
                      ),
                      const SizedBox(height: 4),
                      _buildProbabilityRow(
                        2,
                        DiseaseData.getInfo(secondLabelKey).nameId,
                        secondConfidence ?? 0.0,
                        Colors.grey.shade700,
                      ),
                    ],

                    if (widget.existingRecord != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            'Diperiksa pada ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(widget.existingRecord!.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Panduan Rekomendasi Penanganan Lengkap
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Panduan & Rekomendasi Penanganan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      diseaseInfo.shortDescription,
                      style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 16),

                    // Ciri-ciri Gejala
                    _buildSectionHeader('Ciri-ciri Gejala', Icons.visibility_outlined),
                    ...diseaseInfo.symptoms.map((s) => _buildBulletPoint(s)),
                    const SizedBox(height: 14),

                    // Faktor Lingkungan Pemicu
                    _buildSectionHeader('Faktor Pendukung Perkembangan', Icons.thermostat_outlined),
                    ...diseaseInfo.favorableConditions.map((s) => _buildBulletPoint(s)),
                    const SizedBox(height: 14),

                    // Tindakan Pencegahan
                    _buildSectionHeader('Tindakan Pencegahan', Icons.shield_outlined),
                    ...diseaseInfo.preventionSteps.map((s) => _buildBulletPoint(s)),
                    const SizedBox(height: 14),

                    // Pengendalian Teknis & Hayati
                    _buildSectionHeader('Pengendalian Kultur Teknis & Hayati', Icons.eco_outlined),
                    ...diseaseInfo.technicalControl.map((s) => _buildBulletPoint(s)),
                    const SizedBox(height: 14),

                    // Pengendalian Kimiawi
                    _buildSectionHeader('Rekomendasi Bahan Aktif / Kimiawi', Icons.science_outlined),
                    ...diseaseInfo.chemicalControl.map((s) => _buildBulletPoint(s)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Expandable Card: Rincian Probabilitas 5 Kelas (Sangat penting untuk pengujian skripsi)
            if (widget.classifierResult != null) ...[
              Card(
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text(
                      'Rincian Probabilitas 5 Kelas (Skripsi)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    subtitle: const Text(
                      'Data nilai output softmax untuk evaluasi model',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: widget.classifierResult!.allProbabilities.entries.map((entry) {
                            final info = DiseaseData.getInfo(entry.key);
                            final isTop = entry.key == widget.classifierResult!.labelKey;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      info.nameId,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: entry.value / 100.0,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey.shade200,
                                        color: isTop ? AppTheme.primaryGreen : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      '${entry.value}%',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                        color: isTop ? AppTheme.primaryGreen : AppTheme.textDark,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDarkGreen,
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
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityRow(int rank, String name, double conf, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            '$rank',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Text(
          '${conf.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
