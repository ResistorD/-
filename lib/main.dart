// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/prefs_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();   // Hive (entries)
  await PrefsService.init();     // Hive (prefs) — ОБЯЗАТЕЛЬНО для темы/настроек
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeMode _mapThemeMode(String m) {
    switch (m) {
      case 'light': return ThemeMode.light;
      case 'dark' : return ThemeMode.dark;
      default     : return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем только изменения настроек (темы)
    return ValueListenableBuilder<int>(
      valueListenable: PrefsService.changes,
      builder: (context, _, __) {
        final mode = _mapThemeMode(PrefsService.themeMode);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pressure Diary',
          theme: AppTheme.lightBase(),
          darkTheme: AppTheme.darkBase(),
          themeMode: mode,
          home: const MainScreen(),
          // единый текстовый масштаб и подключение нашей типографики
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final themed = Theme.of(context).copyWith(
              textTheme: buildTextTheme(context),
            );
            return MediaQuery(
              data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Theme(data: themed, child: child ?? const SizedBox.shrink()),
            );
          },
        );
      },
    );
  }
}
