import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../data/disease_data.dart';
import '../models/disease_info.dart';

/// Hasil inferensi klasifikasi citra daun padi
class ClassifierResult {
  final String labelKey;
  final DiseaseInfo diseaseInfo;
  final double confidence; // Nilai persentase (0.0 - 100.0)
  final bool isLowConfidence; // true jika < 75.0%
  final String? secondLabelKey;
  final double? secondConfidence;
  final Map<String, double> allProbabilities; // Seluruh probabilitas 5 kelas
  final int inferenceTimeMs;

  ClassifierResult({
    required this.labelKey,
    required this.diseaseInfo,
    required this.confidence,
    required this.isLowConfidence,
    this.secondLabelKey,
    this.secondConfidence,
    required this.allProbabilities,
    required this.inferenceTimeMs,
  });
}

class ClassifierService {
  static const String _modelAssetPath = 'assets/models/model_padi_multidomain.tflite';
  static const String _labelsAssetPath = 'assets/models/labels_multidomain.txt';

  static const int inputSize = 224;
  static const double confidenceThreshold = 75.0; // 75% ambang batas sesuai PRD

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<String> get labels => _labels;

  /// Memuat model TFLite dan file label dari assets
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Muat labels
      final labelsData = await rootBundle.loadString(_labelsAssetPath);
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 2. Buat interpreter TFLite
      final options = InterpreterOptions();
      // Gunakan multiple threads untuk mempercepat inferensi di perangkat seluler
      options.threads = 2;

      _interpreter = await Interpreter.fromAsset(_modelAssetPath, options: options);
      _isInitialized = true;
      debugPrint('ClassifierService: Model & Labels berhasil dimuat (${_labels.length} kelas).');
    } catch (e) {
      debugPrint('ClassifierService Error saat inisialisasi: $e');
      rethrow;
    }
  }

  /// Menjalankan inferensi pada file gambar daun padi
  Future<ClassifierResult> classifyImage(File imageFile) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
    }

    final stopwatch = Stopwatch()..start();

    // 1. Baca byte citra dan decode menggunakan package `image`
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Gagal memproses file gambar. Format citra tidak didukung.');
    }

    // 2. Resize citra ke 224x224 piksel
    final img.Image resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // 3. Bangun input tensor [1, 224, 224, 3] tipe float32 (nilai 0.0 s.d 255.0)
    // Sesuai spesifikasi PRD Section 5: layer Rescaling sudah tertanam di model.
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    // 4. Siapkan output tensor [1, num_classes]
    final output = List.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0.0),
    );

    // 5. Jalankan inferensi TFLite
    _interpreter!.run(input, output);

    stopwatch.stop();
    final int inferenceTime = stopwatch.elapsedMilliseconds;

    // 6. Parsing hasil output softmax
    final rawProbabilities = output[0];
    final Map<String, double> allProbabilities = {};

    for (int i = 0; i < _labels.length; i++) {
      final percentage = (rawProbabilities[i] * 100.0).clamp(0.0, 100.0);
      allProbabilities[_labels[i]] = double.parse(percentage.toStringAsFixed(2));
    }

    // Urutkan kelas berdasarkan probabilitas tertinggi
    final sortedEntries = allProbabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntry = sortedEntries[0];
    final secondEntry = sortedEntries.length > 1 ? sortedEntries[1] : null;

    final double topConfidence = topEntry.value;
    final bool isLowConfidence = topConfidence < confidenceThreshold;

    final diseaseInfo = DiseaseData.getInfo(topEntry.key);

    return ClassifierResult(
      labelKey: topEntry.key,
      diseaseInfo: diseaseInfo,
      confidence: topConfidence,
      isLowConfidence: isLowConfidence,
      secondLabelKey: secondEntry?.key,
      secondConfidence: secondEntry?.value,
      allProbabilities: allProbabilities,
      inferenceTimeMs: inferenceTime,
    );
  }

  /// Tutup resource interpreter saat tidak lagi digunakan
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
