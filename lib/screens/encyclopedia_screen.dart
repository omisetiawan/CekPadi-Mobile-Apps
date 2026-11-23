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
          // Banner Panduan Belajar / Buku Saku Agronomi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Katalog 5 Kondisi Daun Padi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pelajari gejala visual, penyebab patogen, dan rekomendasi pengendalian resmi Kementan RI tanpa perlu koneksi internet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Daftar 5 Kelas
          ...allDiseases.map((disease) => _buildDiseaseCard(context, disease)),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(BuildContext context, DiseaseInfo disease) {
    final Color badgeColor = disease.isHealthy ? AppTheme.statusHealthy : AppTheme.statusDisease;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.borderMuted, width: 1.2),
      ),
      color: AppTheme.surfaceCard,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              disease.isHealthy ? Icons.eco_rounded : Icons.coronavirus_outlined,
              color: badgeColor,
              size: 24,
            ),
          ),
          title: Text(
            disease.nameId,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disease.scientificName,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.borderMuted),
                ),
                child: Text(
                  'Tipe: ${disease.pathogenType}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: AppTheme.borderMuted, height: 16),
            const SizedBox(height: 4),
            Text(
              disease.shortDescription,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

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
            Icon(icon, size: 16, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppTheme.textPrimary,
                    ),
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
