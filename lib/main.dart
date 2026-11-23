import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale bahasa Indonesia untuk format tanggal riwayat
  await initializeDateFormatting('id_ID', null);

  // Kunci orientasi portrait untuk kestabilan pengambilan foto di sawah
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CekPadiApp());
}

class CekPadiApp extends StatelessWidget {
  const CekPadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CekPadi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
