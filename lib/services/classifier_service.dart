import 'dart:io';
import 'dart:math' as math;
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
  final double confidence; // Nilai persentase (0.0 - 100.0) terkalibrasi
  final bool isLowConfidence; // true jika < confidenceThreshold
  final String? secondLabelKey;
  final double? secondConfidence;
  final Map<String, double> allProbabilities; // Seluruh probabilitas 5 kelas (terkalibrasi)
  final Map<String, double>? rawProbabilities; // Probabilitas mentah sebelum kalibrasi
  final int inferenceTimeMs; // Waktu inferensi TFLite murni
  final int preprocessingTimeMs; // Waktu decode, orientasi EXIF, resize, dan tensor preparation

  ClassifierResult({
    required this.labelKey,
    required this.diseaseInfo,
    required this.confidence,
    required this.isLowConfidence,
    this.secondLabelKey,
    this.secondConfidence,
    required this.allProbabilities,
    this.rawProbabilities,
    required this.inferenceTimeMs,
    required this.preprocessingTimeMs,
  });
}

class ClassifierService {
  static const String _modelAssetPath = 'assets/models/model_padi_multidomain.tflite';
  static const String _labelsAssetPath = 'assets/models/labels_multidomain.txt';

  static const int inputSize = 224;
  static const double confidenceThreshold = 75.0; // 75% ambang batas sesuai validasi

  /// Parameter Temperature Scaling hasil optimasi NLL pada data validasi (Eksperimen 4):
  /// - EfficientNet-B0: T = 0.5534 (kalibrasi.json)
  /// - MobileNetV2: T = 0.5826 (kalibrasi_mobilenetv2.json)
  /// Nilai 1.0 berarti tanpa kalibrasi.
  static const double temperature = 0.5534;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<String> get labels => _labels;

  /// Kalibrasi probabilitas menggunakan Temperature Scaling (T)
  /// z_i = log(p_i + eps) / T; q = softmax(z)
  static List<double> calibrateProbabilities(List<double> rawProbs, double t) {
    if (t <= 0 || (t - 1.0).abs() < 1e-4) return List<double>.from(rawProbs);
    const double eps = 1e-12;
    final List<double> z = rawProbs.map((p) => math.log(p.clamp(eps, 1.0)) / t).toList();
    final double maxZ = z.reduce(math.max);
    final List<double> expZ = z.map((val) => math.exp(val - maxZ)).toList();
    final double sumExp = expZ.reduce((a, b) => a + b);
    if (sumExp <= 0) return List<double>.from(rawProbs);
    return expZ.map((val) => val / sumExp).toList();
  }

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

    final prepStopwatch = Stopwatch()..start();

    // 1. Baca byte citra dan decode menggunakan package `image`
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Gagal memproses file gambar. Format citra tidak didukung.');
    }

    // Pastikan orientasi EXIF dinormalisasi (khusus foto langsung dari kamera HP)
    final img.Image orientedImage = img.bakeOrientation(decodedImage);

    // 2. Resize citra ke 224x224 piksel
    final img.Image resizedImage = img.copyResize(
      orientedImage,
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

    prepStopwatch.stop();
    final int preprocessingTime = prepStopwatch.elapsedMilliseconds;

    // 4. Siapkan output tensor [1, num_classes]
    final output = List.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0.0),
    );

    // 5. Jalankan inferensi TFLite murni (diukur terpisah dari preprocessing)
    final inferStopwatch = Stopwatch()..start();
    _interpreter!.run(input, output);
    inferStopwatch.stop();
    final int inferenceTime = inferStopwatch.elapsedMilliseconds;

    // 6. Parsing hasil output softmax & terapkan Temperature Scaling
    final rawProbabilitiesList = output[0];
    final calibratedProbabilitiesList = calibrateProbabilities(rawProbabilitiesList, temperature);

    final Map<String, double> allProbabilities = {};
    final Map<String, double> rawProbabilitiesMap = {};

    for (int i = 0; i < _labels.length; i++) {
      final calPercentage = (calibratedProbabilitiesList[i] * 100.0).clamp(0.0, 100.0);
      final rawPercentage = (rawProbabilitiesList[i] * 100.0).clamp(0.0, 100.0);
      allProbabilities[_labels[i]] = double.parse(calPercentage.toStringAsFixed(2));
      rawProbabilitiesMap[_labels[i]] = double.parse(rawPercentage.toStringAsFixed(2));
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
      rawProbabilities: rawProbabilitiesMap,
      inferenceTimeMs: inferenceTime,
      preprocessingTimeMs: preprocessingTime,
    );
  }

  /// Tutup resource interpreter saat tidak lagi digunakan
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
