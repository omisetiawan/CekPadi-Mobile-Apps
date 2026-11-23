/// Model representasi data riwayat pemeriksaan daun padi (SQLite).
class DetectionRecord {
  final int? id;
  final String labelKey;
  final String diseaseName;
  final double confidence;
  final bool isLowConfidence;
  final String? secondLabelKey;
  final double? secondConfidence;
  final String imagePath;
  final DateTime createdAt;

  DetectionRecord({
    this.id,
    required this.labelKey,
    required this.diseaseName,
    required this.confidence,
    required this.isLowConfidence,
    this.secondLabelKey,
    this.secondConfidence,
    required this.imagePath,
    required this.createdAt,
  });

  /// Konversi dari Object Dart ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label_key': labelKey,
      'disease_name': diseaseName,
      'confidence': confidence,
      'is_low_confidence': isLowConfidence ? 1 : 0,
      'second_label_key': secondLabelKey,
      'second_confidence': secondConfidence,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Konversi dari Map SQLite ke Object Dart
  factory DetectionRecord.fromMap(Map<String, dynamic> map) {
    return DetectionRecord(
      id: map['id'] as int?,
      labelKey: map['label_key'] as String,
      diseaseName: map['disease_name'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      isLowConfidence: (map['is_low_confidence'] as int) == 1,
      secondLabelKey: map['second_label_key'] as String?,
      secondConfidence: map['second_confidence'] != null
          ? (map['second_confidence'] as num).toDouble()
          : null,
      imagePath: map['image_path'] as String,
      createdAt: DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
    );
  }

  DetectionRecord copyWith({
    int? id,
    String? labelKey,
    String? diseaseName,
    double? confidence,
    bool? isLowConfidence,
    String? secondLabelKey,
    double? secondConfidence,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return DetectionRecord(
      id: id ?? this.id,
      labelKey: labelKey ?? this.labelKey,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      isLowConfidence: isLowConfidence ?? this.isLowConfidence,
      secondLabelKey: secondLabelKey ?? this.secondLabelKey,
      secondConfidence: secondConfidence ?? this.secondConfidence,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
