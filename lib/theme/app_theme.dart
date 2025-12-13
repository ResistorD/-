import 'package:flutter/material.dart';
import 'scale.dart'; // dp()/sp() — используется только в buildTextTheme(context)

// ---------- Palette ----------
class AppPalette {
  static const headerBlue  = Color(0xFF4D83AC); // остаётся главным акцентом UI
  static const summaryBlue = Color(0xFF3973A2);
  static const darkBlue    = Color(0xFF2E5D85); // НОВЫЙ ЦВЕТ ДЛЯ ВСЕХ КНОПОК

  static const bgLight      = Color(0xFFF0F4F8);
  static const surfaceLight = Color(0xFFF9F8FA);

  static const bgDark       = Color(0xFF1A1E21);
  static const surfaceDark  = Color(0xFF202427);

  static const textPrimary  = Color(0xFF1C1C1C);

  static const iconActive   = Color(0xFF6B9DC0);

  static const dotGreen = Color(0xFF22C55E);
  static const dotBlue  = Color(0xFF60A5FA);
  static const dotRed   = Color(0xFFE11D48);
}

// ---------- Extra colors ----------
@immutable
class AppExtraColors extends ThemeExtension<AppExtraColors> {
  const AppExtraColors({required this.summaryBlue});
  final Color summaryBlue;

  @override
  AppExtraColors copyWith({Color? summaryBlue}) =>
      AppExtraColors(summaryBlue: summaryBlue ?? this.summaryBlue);

  @override
  AppExtraColors lerp(ThemeExtension<AppExtraColors>? other, double t) {
    if (other is! AppExtraColors) return this;
    return AppExtraColors(
      summaryBlue: Color.lerp(summaryBlue, other.summaryBlue, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  Color get headerBlue  => Theme.of(this).colorScheme.primary;
  Color get summaryBlue =>
      Theme.of(this).extension<AppExtraColors>()!.summaryBlue;
}

// ---------- Типографика: масштабируемая (через sp(context)) ----------
TextTheme buildTextTheme(BuildContext context) {
  return TextTheme(
    // Заголовок страницы — 26
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 26),
      fontWeight: FontWeight.w700,
    ),
    // Чип периода — 16
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 16),
      fontWeight: FontWeight.w600,
    ),
    // Цифры сводки — 30
    headlineSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 30),
      fontWeight: FontWeight.w700,
    ),
    // Подписи в сводке — 24
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 24),
      fontWeight: FontWeight.w400,
    ),
    // Время слева — 16
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 16),
      fontWeight: FontWeight.w600,
    ),
    // «сист/диаст» — 22
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 22),
      fontWeight: FontWeight.w700,
    ),
    // Дата секции — 16
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 16),
      fontWeight: FontWeight.w700,
    ),
  );
}

// ---------- БАЗОВЫЙ textTheme (без MediaQuery) ----------
const TextTheme _baseTextTheme = TextTheme(
  titleLarge:    TextStyle(fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w700),
  bodyMedium:    TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
  headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700),
  bodySmall:     TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w400),
  labelLarge:    TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
  titleMedium:   TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700),
  titleSmall:    TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700),
);

// ---------- Themes ----------
class AppTheme {
  // LIGHT base (без контекста — безопасно для MaterialApp.theme)
  static ThemeData lightBase() {
    // ВНИМАНИЕ: primary остаётся headerBlue — так мы ничего лишнего не перекрасим.
    final base = ColorScheme.fromSeed(
      seedColor: AppPalette.headerBlue,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      primary: AppPalette.headerBlue,
      onPrimary: Colors.white,
      surface: AppPalette.surfaceLight,
      onSurface: AppPalette.textPrimary,
      secondary: AppPalette.iconActive,
      error: AppPalette.dotRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: _baseTextTheme,
      scaffoldBackgroundColor: AppPalette.bgLight,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Color(0x33000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Color(0x22000000)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),

      // ---- ВАЖНО: единообразный цвет всех КНОПОК ----
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppPalette.darkBlue,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.darkBlue,
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.darkBlue,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.darkBlue,
          side: const BorderSide(color: AppPalette.darkBlue),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.darkBlue,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppPalette.darkBlue),
          iconColor:      WidgetStatePropertyAll(AppPalette.darkBlue),
        ),
      ),

      extensions: const [ AppExtraColors(summaryBlue: AppPalette.summaryBlue) ],
    );
  }

  // DARK base
  static ThemeData darkBase() {
    final base = ColorScheme.fromSeed(
      seedColor: AppPalette.headerBlue,
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      primary: AppPalette.headerBlue,
      onPrimary: Colors.white,
      surface: AppPalette.surfaceDark,
      onSurface: Colors.white,
      secondary: AppPalette.iconActive,
      error: AppPalette.dotRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: _baseTextTheme,
      scaffoldBackgroundColor: AppPalette.bgDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C343B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x33FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x22FFFFFF)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),

      // ---- те же правила для тёмной темы ----
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppPalette.darkBlue,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.darkBlue,
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.darkBlue,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.darkBlue,
          side: const BorderSide(color: AppPalette.darkBlue),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.darkBlue,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppPalette.darkBlue),
          iconColor:      WidgetStatePropertyAll(AppPalette.darkBlue),
        ),
      ),

      extensions: const [
        AppExtraColors(summaryBlue: AppPalette.summaryBlue),
      ],
    );
  }
}
