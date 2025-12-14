import 'package:flutter/material.dart';
import 'scale.dart'; // dp()/sp() — используется только в buildTextTheme(context)

// ---------- Palette ----------
class AppPalette {
  // Цвета из Figma эскизов
  static const primary     = Color(0xFF3D8BFC); // сине-голубой для акцентов и кнопок
  static const background  = Color(0xFFFFFFFF); // чистый белый для основного фона
  static const secondary   = Color(0xFFF5F7FA); // светло-серый для разделителей и второстепенных элементов
  static const error       = Color(0xFFE53E3E); // красный для ошибок и предупреждений
  static const success     = Color(0xFF38A169); // зеленый для успешных действий

  // Цвета текста из Figma эскизов
  static const textPrimary   = Color(0xFF1A202C); // темно-серый почти черный
  static const textSecondary = Color(0xFF718096); // серый для подсказок
  static const textPlaceholder = Color(0xFFA0AEC0); // светло-серый для placeholder

  // Сохраняем старые цвета для обратной совместимости (временно)
  static const headerBlue  = Color(0xFF4D83AC); // остаётся главным акцентом UI
  static const summaryBlue = Color(0xFF3973A2);
  static const darkBlue    = Color(0xFF2E5D85); // НОВЫЙ ЦВЕТ ДЛЯ ВСЕХ КНОПОК

  static const bgLight      = Color(0xFFF0F4F8);
  static const surfaceLight = Color(0xFFF9F8FA);

  static const bgDark       = Color(0xFF1A1E21);
  static const surfaceDark  = Color(0xFF202427);

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
    // Заголовки экранов: 24sp, полужирный
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 24),
      fontWeight: FontWeight.w600,
      color: AppPalette.textPrimary,
    ),
    // Подзаголовки: 18sp, нормальный
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 18),
      fontWeight: FontWeight.w400,
      color: AppPalette.textPrimary,
    ),
    // Основной текст: 16sp, нормальный
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 16),
      fontWeight: FontWeight.w400,
      color: AppPalette.textPrimary,
    ),
    // Вспомогательный текст: 14sp, нормальный
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 14),
      fontWeight: FontWeight.w400,
      color: AppPalette.textSecondary,
    ),
    // Мелкий текст: 12sp
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: sp(context, 12),
      fontWeight: FontWeight.w400,
      color: AppPalette.textSecondary,
    ),
  );
}

// ---------- БАЗОВЫЙ textTheme (без MediaQuery) ----------
const TextTheme _baseTextTheme = TextTheme(
  titleLarge:    TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
  titleMedium:   TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400, color: AppPalette.textPrimary),
  bodyLarge:     TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: AppPalette.textPrimary),
  bodyMedium:    TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: AppPalette.textSecondary),
  bodySmall:     TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: AppPalette.textSecondary),
);

// ---------- Themes ----------
class AppTheme {
  // LIGHT base (без контекста — безопасно для MaterialApp.theme)
  static ThemeData lightBase() {
    // ВНИМАНИЕ: primary остаётся headerBlue — так мы ничего лишнего не перекрасим.
    final base = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      background: AppPalette.background,
      surface: AppPalette.secondary,
      onSurface: AppPalette.textPrimary,
      secondary: AppPalette.primary,
      onSecondary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      outline: AppPalette.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: _baseTextTheme,
      scaffoldBackgroundColor: AppPalette.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppPalette.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppPalette.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppPalette.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // ---- ВАЖНО: единообразный цвет всех КНОПОК ----
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        sizeConstraints: BoxConstraints.tightFor(width: 48, height: 48),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(48, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primary,
          side: BorderSide(color: AppPalette.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(48, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppPalette.primary),
          iconColor:      WidgetStatePropertyAll(AppPalette.primary),
        ),
      ),

      extensions: const [ AppExtraColors(summaryBlue: AppPalette.summaryBlue) ],
    );
  }

  // DARK base
  static ThemeData darkBase() {
    final base = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      background: AppPalette.bgDark,
      surface: AppPalette.surfaceDark,
      onSurface: Colors.white,
      secondary: AppPalette.primary,
      onSecondary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      outline: AppPalette.primary,
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
      cardTheme: CardTheme(
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppPalette.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppPalette.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppPalette.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // ---- те же правила для тёмной темы ----
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        sizeConstraints: BoxConstraints.tightFor(width: 48, height: 48),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(48, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primary,
          side: BorderSide(color: AppPalette.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(48, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppPalette.primary),
          iconColor:      WidgetStatePropertyAll(AppPalette.primary),
        ),
      ),

      extensions: const [
        AppExtraColors(summaryBlue: AppPalette.summaryBlue),
      ],
    );
  }
}
