import 'package:flutter/material.dart';

/// Tema Aplikasi CekPadi — Fungsional, Membumi, Kontras Tinggi untuk Petani
/// Mengikuti panduan DESIGN.md dan standar anti-slop:
/// - 100% Native Offline Typography (tanpa panggilan jaringan google_fonts)
/// - Kontras tinggi memenuhi standar WCAG AA/AAA (> 4.5:1) agar mudah dibaca di bawah terik matahari sawah.
class AppTheme {
  // Palet Warna Utama (Berdasarkan DESIGN.md)
  static const Color primaryGreen = Color(0xFF1E5E3A); // Hijau Daun Padi Tua
  static const Color primaryContainer = Color(0xFFE5F2E9); // Hijau Muda Kontainer
  static const Color surfaceBackground = Color(0xFFF7F9F6); // Latar Putih Gading Alami
  static const Color surfaceCard = Colors.white; // Permukaan Kartu Solid
  static const Color borderMuted = Color(0xFFDDE3DC); // Garis Batas Kartu yang Jelas
  static const Color textPrimary = Color(0xFF142218); // Teks Utama Arang Pekat
  static const Color textSecondary = Color(0xFF4A5D50); // Teks Sekunder Lumut Tua

  // Warna Sinyal & Status Agronomi (Bukan Hiasan)
  static const Color accentAmber = Color(0xFFD97706); // Bulir Padi Emas
  static const Color statusHealthy = Color(0xFF1E5E3A); // Daun Sehat
  static const Color statusDisease = Color(0xFFB91C1C); // Terindikasi Penyakit
  static const Color statusWarning = Color(0xFFC2410C); // Keyakinan Rendah / Perlu Foto Ulang

  // Aliases untuk kompatibilitas kode
  static const Color primaryLightGreen = primaryContainer;
  static const Color primaryDarkGreen = primaryGreen;
  static const Color textDark = textPrimary;
  static const Color textMuted = textSecondary;
  static const Color dangerRed = statusDisease;
  static const Color warningOrange = statusWarning;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: primaryGreen,
        secondary: accentAmber,
        onSecondary: Colors.white,
        surface: surfaceBackground,
        onSurface: textPrimary,
        error: statusDisease,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderMuted, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52), // Target sentuh jempol petani
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: borderMuted, width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 2,
        height: 68,
        indicatorColor: primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryGreen,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
      ),
    );
  }
}
