import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cek_padi/data/disease_data.dart';
import 'package:cek_padi/models/detection_record.dart';
import 'package:cek_padi/services/classifier_service.dart';

void main() {
  group('DiseaseData & Labels Validation', () {
    test('Labels multidomain harus tepat 5 kelas dan terdaftar di DiseaseData', () {
      final labelsFile = File('assets/models/labels_multidomain.txt');
      expect(labelsFile.existsSync(), isTrue, reason: 'File labels_multidomain.txt harus ada di assets/models/');

      final labels = labelsFile
          .readAsLinesSync()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      expect(labels.length, equals(5));

      final expectedLabels = [
        'Bacterial_Leaf_Blight',
        'Brown_Spot',
        'Healthy',
        'Leaf_Blast',
        'Tungro',
      ];
      expect(labels, equals(expectedLabels));

      for (final label in labels) {
        final info = DiseaseData.getInfo(label);
        expect(info.id, equals(label));
        expect(info.nameId.isNotEmpty, isTrue);
        expect(info.symptoms.isNotEmpty, isTrue);
        expect(info.preventionSteps.isNotEmpty, isTrue);
        expect(info.technicalControl.isNotEmpty, isTrue);
        expect(info.chemicalControl.isNotEmpty, isTrue);
      }
    });

    test('Deteksi kelas Sehat (Healthy) memiliki atribut isHealthy = true', () {
      final healthyInfo = DiseaseData.getInfo('Healthy');
      expect(healthyInfo.isHealthy, isTrue);
      expect(healthyInfo.pathogenType, equals('Sehat'));
    });
  });

  group('DetectionRecord SQLite Serialization', () {
    test('Konversi toMap dan fromMap harus konsisten', () {
      final now = DateTime.now();
      final record = DetectionRecord(
        id: 1,
        labelKey: 'Leaf_Blast',
        diseaseName: 'Blas Daun',
        confidence: 88.5,
        isLowConfidence: false,
        secondLabelKey: 'Brown_Spot',
        secondConfidence: 8.2,
        imagePath: '/path/to/image.jpg',
        createdAt: now,
      );

      final map = record.toMap();
      final fromMap = DetectionRecord.fromMap(map);

      expect(fromMap.id, equals(record.id));
      expect(fromMap.labelKey, equals(record.labelKey));
      expect(fromMap.diseaseName, equals(record.diseaseName));
      expect(fromMap.confidence, equals(record.confidence));
      expect(fromMap.isLowConfidence, equals(record.isLowConfidence));
      expect(fromMap.secondLabelKey, equals(record.secondLabelKey));
      expect(fromMap.secondConfidence, equals(record.secondConfidence));
      expect(fromMap.imagePath, equals(record.imagePath));
    });
  });

  group('ClassifierService Threshold & Calibration', () {
    test('Ambang batas keyakinan harus 75%', () {
      expect(ClassifierService.confidenceThreshold, equals(75.0));
      expect(ClassifierService.inputSize, equals(224));
    });

    test('Kalibrasi Temperature Scaling menormalkan jumlah probabilitas menjadi 1.0', () {
      final rawProbs = [0.70, 0.20, 0.05, 0.03, 0.02];
      final calibrated = ClassifierService.calibrateProbabilities(rawProbs, ClassifierService.temperature);
      expect(calibrated.length, equals(5));
      final sum = calibrated.reduce((a, b) => a + b);
      expect((sum - 1.0).abs() < 1e-5, isTrue);
    });
  });
}
