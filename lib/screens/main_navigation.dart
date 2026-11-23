import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier_service.dart';
import '../services/image_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_helper.dart';
import 'about_screen.dart';
import 'encyclopedia_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'result_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Membuka modal pilihan kamera / galeri
  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Metode Pemeriksaan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Foto akan dipotong otomatis rasio 1:1 sebelum dipindai',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryLightGreen,
                  child: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
                ),
                title: const Text('Kamera Langsung', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ambil foto helai daun di lapangan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _processScan(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFFF8E1),
                  child: const Icon(Icons.photo_library, color: AppTheme.accentAmber),
                ),
                title: const Text('Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih foto yang tersimpan di galeri'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _processScan(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processScan(ImageSource source) async {
    final croppedFile = await ImageHelper.pickAndCropImage(
      context: context,
      source: source,
    );

    if (croppedFile == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Mendiagnosis...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final classifier = ClassifierService();
      await classifier.initialize();
      final result = await classifier.classifyImage(croppedFile);
      final savedPath = await ImageStorageService.saveImage(croppedFile);

      if (mounted) {
        Navigator.pop(context); // Tutup dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              classifierResult: result,
              imagePath: savedPath,
              isFromScan: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const HistoryScreen(),
      const EncyclopediaScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showScanOptions,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        tooltip: 'Pindai Daun Padi',
        child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryGreen),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primaryGreen),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppTheme.primaryGreen),
            label: 'Ensiklopedia',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info, color: AppTheme.primaryGreen),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}
