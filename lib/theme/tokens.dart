// FILE: lib/theme/tokens.dart
// ЕДИНЫЕ токены размеров/цветов для шапки и карточки.
// Важно: этот файл заменяет прежние дубли — имена объявлены ОДИН РАЗ.

import 'package:flutter/material.dart';
import 'scale.dart';

// Палитра
class C {
  static const headerBlue  = Color(0xFF4D83AC); // фон шапки
  static const summaryBlue = Color(0xFF3973A2); // фон синей карточки
  static const darkBlue    = Color(0xFF2E5D85); // цвет FAB/иконок нижнего бара
}

// Централизованные токены домашнего экрана
class HomeTokens {
  /// Единый горизонтальный паддинг экрана (используем везде: саммари, полка, список)
  static double pageHPad       (BuildContext c) => dp(c, 16);

  // нейтральный цвет и размер маленьких иконок (для "пилюли")
  static Color  iconNeutral(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withOpacity(0.75);
  static double iconSizeXs(BuildContext c) => dp(c, 16);

  // Шрифты
  static double titleFont   (BuildContext c) => sp(c, 26); // «Мой дневник»
  static double tokenFont   (BuildContext c) => sp(c, 16); // текст токена
  static double bigDigits   (BuildContext c) => sp(c, 30); // 120/80

  // ── НОВОЕ: отдельные кегли для пульса и времени ────────────────────────────
  static double pulseNumFont (BuildContext c) => sp(c, 24); // число пульса (крупнее)
  static double pulseUnitFont(BuildContext c) => sp(c, 20); // «уд/мин»
  static double timeFont     (BuildContext c) => sp(c, 20); // время

  // старые info/hint оставляем на месте, если где-то используются
  static double infoFont    (BuildContext c) => sp(c, 16);
  static double hintFont    (BuildContext c) => sp(c, 18);
  static double sectionFont (BuildContext c) => sp(c, 16); // заголовок даты в журнале

  // Геометрия шапки
  static double blueH     (BuildContext c) => dp(c, 169);
  static double lightH    (BuildContext c) => dp(c,  82);
  static double overlap   (BuildContext c) => dp(c,  50);
  static double side      (BuildContext c) => dp(c,  20);
  static double titleTop  (BuildContext c) => dp(c,  20);

  // Токен периода
  static double tokenHeight(BuildContext c) => dp(c, 32);     // ЖЁСТКАЯ высота токена
  static double tokenPadH  (BuildContext c) => dp(c, 10);     // горизонтальные поля
  static double tokenRadius(BuildContext c) => dp(c, 5);
  static double arrowSize  (BuildContext c) => dp(c, 24);
  static Color  tokenBg    (BuildContext c) => Colors.white.withValues(alpha: .15);
  static Color  tokenFg    (BuildContext c) => Colors.white;
  static Color  arrowColor (BuildContext c) => tokenFg(c);    // ← чтобы не ловить ошибку

  // Цвет «полки» и фона страницы журнала
  static Color  shelfColor (BuildContext c) => const Color(0xFFF9F8FA); // светлая полоса
  static Color  pageBg     (BuildContext c) => const Color(0xFFF0F4F8); // общий фон списка

  // Карточка «последнее измерение»
  static double cardHeight (BuildContext c) => dp(c, 120);    // запас от overflow
  static double cardPadV   (BuildContext c) => dp(c, 8);     // отступы сверху/снизу
  static double cardPadH   (BuildContext c) => dp(c, 16);     // отступы слева/справа
  static double cardRadius (BuildContext c) => dp(c, 10);
  static double checkSize  (BuildContext c) => dp(c, 42);
  static Color  checkColor (BuildContext c) => const Color(0xFF6B9DC0);
  static Color  cardBg     (BuildContext c) => C.summaryBlue;

  // Надписи вокруг карточки
  static double recordsTop   (BuildContext c) => dp(c, 36);
  static double recordsFont  (BuildContext c) => sp(c, 16);
  static Color  recordsColor (BuildContext c) => const Color(0xFFBFD4E7);

  // Вынесенная подпись «среднее за 7д»
  static double avgLabelFont (BuildContext c) => sp(c, 18);
  static Color  avgLabelColor(BuildContext c) => const Color(0xFF325674);   // ← по макету

  // ── НОВОЕ: удобные отступы для позиционирования вынесенной подписи ─────────
  static double avgPadTop    (BuildContext c) => dp(c, 72);
  static double avgPadBottom (BuildContext c) => dp(c, 6);
  static double avgPadLeft   (BuildContext c) => dp(c, 36);
  static double avgPadRight  (BuildContext c) => dp(c, 16);

  // ── НОВОЕ: управляем паддингом заголовка даты ─────────────────────────────
  static double sectionPadTop   (BuildContext c) => dp(c, 12);
  static double sectionPadBottom(BuildContext c) => dp(c, 8);

  // ── Контраст на границе полки ──
  static bool   shelfDividerEnabled(BuildContext c) => true;
  static Color  shelfDividerColor  (BuildContext c) => const Color(0x33000000); // 20% чёрного
  static double shelfDividerHeight (BuildContext c) => 0.5;                  // волосок

  // >>> НОВОЕ: мягкая тень под полкой (как у BottomAppBar)
  static bool   shelfShadowEnabled (BuildContext c) => true;
  static double shelfShadowHeight  (BuildContext c) => dp(c, 2);               // высота градиента
  static Color  shelfShadowColor   (BuildContext c) => const Color(0x24000000);

  // ── Зазоры внутри синей карточки ──
  static double cardGapAfterTitle   (BuildContext c) => dp(c, 5);
  static double cardGapBetweenRows  (BuildContext c) => dp(c, 5);

  // Цвет заголовка даты в журнале
  static Color  sectionColor (BuildContext c, ColorScheme cs)
  => cs.onSurface.withValues(alpha: .85);
}
