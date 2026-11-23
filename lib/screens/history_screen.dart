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
    // Otomatis sinkronisasi data dengan database setiap kali ada penambahan/penghapusan
    DatabaseHelper.historyChangeNotifier.addListener(_loadHistory);
    _loadHistory();
  }

  @override
  void dispose() {
    DatabaseHelper.historyChangeNotifier.removeListener(_loadHistory);
    super.dispose();
  }

  Future<void> _loadHistory() async {
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
        title: const Text('Hapus Catatan Ini?'),
        content: Text('Catatan pemeriksaan "${record.diseaseName}" beserta fotonya akan dihapus permanen.'),
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

    if (confirm == true && mounted) {
      if (record.id != null) {
        await DatabaseHelper.instance.deleteRecord(record.id!);
      }
      await ImageStorageService.deleteImage(record.imagePath);
      // Listener otomatis memperbarui tampilan
    }
  }

  Future<void> _clearAllHistory() async {
    if (_records.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Seluruh Riwayat?'),
        content: const Text(
          'Semua catatan riwayat pemeriksaan dan seluruh foto yang tersimpan akan dihapus dari memori HP.',
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
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DatabaseHelper.instance.clearAllRecords();
      await ImageStorageService.clearAllImages();
      // Listener otomatis memperbarui tampilan
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
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.statusDisease),
              tooltip: 'Hapus Semua Riwayat',
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          // Kolom Pencarian Cepat Fungsional
          if (_records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari penyakit...',
                  hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderMuted),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderMuted),
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
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : filteredRecords.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppTheme.primaryGreen,
                        child: ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _filterQuery.isNotEmpty
                                          ? Icons.search_off_rounded
                                          : Icons.folder_open_rounded,
                                      size: 48,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _filterQuery.isNotEmpty
                                          ? 'Tidak ditemukan penyakit "$_filterQuery"'
                                          : 'Belum ada data pemeriksaan tersimpan',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _filterQuery.isNotEmpty
                                          ? 'Gunakan kata kunci lain atau bersihkan pencarian.'
                                          : 'Lakukan pemeriksaan daun padi untuk melihat riwayatnya di sini.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
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
                                      // Foto Hasil Crop
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 64,
                                          height: 64,
                                          child: Image.file(
                                            File(record.imagePath),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: AppTheme.primaryContainer,
                                              child: const Icon(Icons.broken_image, color: AppTheme.textSecondary),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Keterangan Hasil
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              record.diseaseName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
                                                  .format(record.createdAt),
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                statusLabel,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Persentase & Tombol Hapus
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
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.textSecondary),
                                            onPressed: () => _deleteRecord(record),
                                            tooltip: 'Hapus pemeriksaan',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                          ),
                                        ],
                                      ),
                                    ],
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
