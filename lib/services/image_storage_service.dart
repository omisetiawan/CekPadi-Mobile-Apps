import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service untuk mengelola penyimpanan lokal file foto daun hasil crop
/// Menyimpan ke direktori internal aplikasi agar tidak mengotori galeri pengguna.
class ImageStorageService {
  static const String _folderName = 'history_images';

  /// Mendapatkan direktori penyimpanan foto riwayat
  static Future<Directory> _getStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final historyDir = Directory(p.join(appDir.path, _folderName));

    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    return historyDir;
  }

  /// Menyalin file gambar crop ke penyimpanan internal permanen aplikasi
  /// Mengembalikan path absolut file gambar yang disimpan
  static Future<String> saveImage(File sourceFile) async {
    try {
      final storageDir = await _getStorageDirectory();
      final extension = p.extension(sourceFile.path).isNotEmpty
          ? p.extension(sourceFile.path)
          : '.jpg';
      final fileName = 'padi_${DateTime.now().millisecondsSinceEpoch}$extension';
      final targetPath = p.join(storageDir.path, fileName);

      final savedFile = await sourceFile.copy(targetPath);
      return savedFile.path;
    } catch (e) {
      debugPrint('ImageStorageService: Gagal menyimpan gambar: $e');
      // Jika terjadi kendala direktori aplikasi, fallback ke path asli
      return sourceFile.path;
    }
  }

  /// Menghapus satu file gambar riwayat dari penyimpanan
  static Future<bool> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ImageStorageService: Gagal menghapus file ($filePath): $e');
      return false;
    }
  }

  /// Menghapus seluruh file foto riwayat yang tersimpan di direktori
  static Future<void> clearAllImages() async {
    try {
      final storageDir = await _getStorageDirectory();
      if (await storageDir.exists()) {
        final List<FileSystemEntity> files = storageDir.listSync();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('ImageStorageService: Gagal membersihkan foto riwayat: $e');
    }
  }
}
