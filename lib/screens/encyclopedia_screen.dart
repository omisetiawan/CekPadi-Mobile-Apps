import 'package:flutter/material.dart';
import '../data/disease_data.dart';
import '../models/disease_info.dart';
import '../theme/app_theme.dart';

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DiseaseInfo> allDiseases = DiseaseData.getAllDiseases();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensiklopedia Penyakit Padi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Panduan Belajar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Katalog 5 Kondisi Daun Padi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pelajari gejala visual, penyebab patogen, dan rekomendasi pengendalian resmi Kementan RI tanpa perlu koneksi internet.',
                        style: TextStyle(fontSize: 11.5, color: AppTheme.textDark, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daftar 5 Kelas
          ...allDiseases.map((disease) => _buildDiseaseCard(context, disease)),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(BuildContext context, DiseaseInfo disease) {
    final Color badgeColor = disease.isHealthy ? AppTheme.primaryGreen : AppTheme.dangerRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            backgroundColor: badgeColor.withValues(alpha: 0.12),
            child: Icon(
              disease.isHealthy ? Icons.eco : Icons.coronavirus_outlined,
              color: badgeColor,
            ),
          ),
          title: Text(
            disease.nameId,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disease.scientificName,
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Tipe: ${disease.pathogenType}',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Text(
              disease.shortDescription,
              style: const TextStyle(fontSize: 13, height: 1.45, color: AppTheme.textDark),
            ),
            const SizedBox(height: 14),

            _buildDetailSection('Ciri-ciri Gejala Lapangan', Icons.visibility_outlined, disease.symptoms),
            const SizedBox(height: 12),
            _buildDetailSection('Faktor Pemicu Perkembangan', Icons.thermostat_outlined, disease.favorableConditions),
            const SizedBox(height: 12),
            _buildDetailSection('Langkah Pencegahan', Icons.shield_outlined, disease.preventionSteps),
            const SizedBox(height: 12),
            _buildDetailSection('Pengendalian Kultur Teknis & Hayati', Icons.eco_outlined, disease.technicalControl),
            const SizedBox(height: 12),
            _buildDetailSection('Rekomendasi Kimiawi / Pengendalian Vektor', Icons.science_outlined, disease.chemicalControl),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppTheme.primaryGreen),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primaryDarkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppTheme.textDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
