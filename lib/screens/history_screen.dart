import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../models/detection_record.dart';
import '../services/image_storage_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DetectionRecord> _records = [];
  bool _isLoading = true;
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllRecords();
    if (mounted) {
      setState(() {
        _records = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecord(DetectionRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Hapus riwayat diagnosis "${record.diseaseName}" beserta fotonya?'),
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

    if (confirm == true && mounted) {
      if (record.id != null) {
        await DatabaseHelper.instance.deleteRecord(record.id!);
      }
      await ImageStorageService.deleteImage(record.imagePath);
      _loadHistory();
    }
  }

  Future<void> _clearAllHistory() async {
    if (_records.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text(
          'Semua catatan riwayat pemeriksaan dan seluruh foto yang tersimpan akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.clearAllRecords();
      await ImageStorageService.clearAllImages();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _filterQuery.isEmpty
        ? _records
        : _records.where((r) {
            final query = _filterQuery.toLowerCase();
            return r.diseaseName.toLowerCase().contains(query) ||
                r.labelKey.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        actions: [
          if (_records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.dangerRed),
              tooltip: 'Hapus Semua',
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          // Kolom Pencarian Cepat
          if (_records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama penyakit...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primaryGreen),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _filterQuery = val;
                  });
                },
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecords.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _filterQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.folder_open_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _filterQuery.isNotEmpty
                                        ? 'Penyakit "$_filterQuery" tidak ditemukan'
                                        : 'Belum ada data pemeriksaan',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _filterQuery.isNotEmpty
                                        ? 'Coba gunakan kata kunci pencarian lain'
                                        : 'Ambil foto daun padi untuk mulai mendiagnosis',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppTheme.primaryGreen,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredRecords.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            final bool isHealthy = record.labelKey == 'Healthy';
                            final Color badgeColor = record.isLowConfidence
                                ? AppTheme.warningOrange
                                : (isHealthy ? AppTheme.primaryGreen : AppTheme.dangerRed);

                            return Dismissible(
                              key: Key('record_${record.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.dangerRed,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                _deleteRecord(record);
                              },
                              child: Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
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
                                      _loadHistory();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Foto Hasil Crop
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 68,
                                            height: 68,
                                            child: Image.file(
                                              File(record.imagePath),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Keterangan Hasil
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.diseaseName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
                                                    .format(record.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: badgeColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  record.isLowConfidence
                                                      ? 'Keyakinan Rendah'
                                                      : (isHealthy ? 'Kondisi Sehat' : 'Terindikasi Penyakit'),
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: badgeColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Persentase
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${record.confidence.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: badgeColor,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                              onPressed: () => _deleteRecord(record),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
