/// Model untuk menyimpan informasi detail ensiklopedia & rekomendasi penanganan penyakit padi.
class DiseaseInfo {
  final String id; // Kunci label model (e.g. 'Bacterial_Leaf_Blight')
  final String nameId; // Nama umum Indonesia
  final String scientificName; // Nama ilmiah patogen atau bahasa Inggris
  final String pathogenType; // 'Bakteri', 'Jamur', 'Virus', 'Sehat'
  final bool isHealthy;
  final String shortDescription;
  final List<String> symptoms; // Gejala visual pada daun
  final List<String> favorableConditions; // Faktor pemicu / kondisi lingkungan
  final List<String> preventionSteps; // Tindakan pencegahan
  final List<String> technicalControl; // Pengendalian teknis / biologis
  final List<String> chemicalControl; // Rekomendasi bahan aktif (bila relevan)

  const DiseaseInfo({
    required this.id,
    required this.nameId,
    required this.scientificName,
    required this.pathogenType,
    this.isHealthy = false,
    required this.shortDescription,
    required this.symptoms,
    required this.favorableConditions,
    required this.preventionSteps,
    required this.technicalControl,
    required this.chemicalControl,
  });
}
