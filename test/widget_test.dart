import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cek_padi/screens/about_screen.dart';
import 'package:cek_padi/screens/encyclopedia_screen.dart';
import 'package:cek_padi/theme/app_theme.dart';

void main() {
  testWidgets('EncyclopediaScreen menampilkan katalog 5 kelas daun padi', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const EncyclopediaScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ensiklopedia Penyakit Padi'), findsOneWidget);
    expect(find.text('Katalog 5 Kondisi Daun Padi'), findsOneWidget);

    // Pastikan 5 nama kelas tertera di katalog
    expect(find.text('Hawar Daun Bakteri (Kresek)'), findsOneWidget);
    expect(find.text('Bercak Cokelat'), findsOneWidget);
    expect(find.text('Daun Sehat'), findsOneWidget);
    expect(find.text('Blas Daun'), findsOneWidget);
    expect(find.text('Penyakit Tungro'), findsOneWidget);
  });

  testWidgets('AboutScreen menampilkan informasi skripsi dan spesifikasi AI', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AboutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('CekPadi'), findsOneWidget);
    expect(find.text('Romi Setiawan'), findsOneWidget);
    expect(find.text('D4 Rekayasa Perangkat Lunak'), findsOneWidget);
    expect(find.text('Politeknik Negeri Indramayu'), findsOneWidget);
    expect(find.text('MobileNetV2 (Transfer Learning)'), findsOneWidget);
  });
}
