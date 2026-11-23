import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

/// Helper untuk pengambilan foto (Kamera/Galeri) dan pemotongan gambar rasio 1:1
class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Mengambil foto dari Kamera atau Galeri, lalu langsung membuka pemotong rasio 1:1
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    try {
      // 1. Ambil citra dari sumber
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      // 2. Buka layar crop dengan rasio terkunci 1:1 (persegi)
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fokuskan ke Daun (1:1)',
            toolbarColor: AppTheme.primaryGreen,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppTheme.primaryGreen,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Fokuskan ke Daun (1:1)',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      debugPrint('ImageHelper Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat memproses gambar: $e'),
            backgroundColor: AppTheme.statusDisease,
          ),
        );
      }
      return null;
    }
  }
}
