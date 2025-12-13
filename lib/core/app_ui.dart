import 'package:flutter/material.dart';

/// ЕДИНЫЕ UI-КОНСТАНТЫ ПРОЕКТА
@immutable
class AppUI {
  const AppUI._();

  // Отступы/гапы
  static const double hPad = 20;        // Горизонтальные поля для списка/заголовков
  static const double vGap = 12;        // Базовый вертикальный зазор
  static const double gap = 8;          // Малый зазор

  // Колонка времени слева в журнале
  static const double timeColW = 78;
  static const double timeDotGap = 16;

  // Карточки/радиусы/тени
  static const double cardRadius = 14;
  static const double cardElevation = 6;
  static const EdgeInsets entryCardMargin =
  EdgeInsets.symmetric(horizontal: hPad, vertical: 8);

  // «Сводка» (синяя карточка)
  static const EdgeInsets summaryPad = EdgeInsets.fromLTRB(16, 12, 16, 12);

  // Индикаторы
  static const double dotSize = 20;

  // Ввод и экран записи
  static const double fieldHeight = 48;
  static const double saveBtnHeight = 44;

  // Анимации
  static const Duration animFast = Duration(milliseconds: 150);

  // Цвета для текста/иконок журнала
  static const Color timeColor = Color(0xFF325674);
  static const Color iconColor = Color(0xFF325674);
  static const Color dayCaption = Color(0xFF6B7B8C);

  // ===== Совместимость со «старыми» короткими именами =====
  static const double h = hPad;                 // былой «горизонтальный»
  static const double v = vGap;                 // былой «вертикальный»
  static const double r = cardRadius;           // былой «радиус»
  static const double padHeight = fieldHeight;  // высота поля ввода
}

// -------- Временные адаптеры для старых import'ов (чтобы ничего не падало) -----
@Deprecated('Use AppUI instead')
class UI {
  static const hPad = AppUI.hPad;
  static const vGap = AppUI.vGap;
  static const timeColW = AppUI.timeColW;
  static const timeDotGap = AppUI.timeDotGap;

  static const cardRadius = AppUI.cardRadius;
  static const cardElevation = AppUI.cardElevation;
  static const entryCardMargin = AppUI.entryCardMargin;

  static const summaryPad = AppUI.summaryPad;
  static const dotSize = AppUI.dotSize;

  static const fieldHeight = AppUI.fieldHeight;
  static const saveBtnHeight = AppUI.saveBtnHeight;

  static const animFast = AppUI.animFast;

  static const timeColor = AppUI.timeColor;
  static const iconColor = AppUI.iconColor;
  static const dayCaption = AppUI.dayCaption;

  // старые алиасы
  static const h = AppUI.h;
  static const v = AppUI.v;
  static const r = AppUI.r;
  static const padHeight = AppUI.padHeight;
  static const gap = AppUI.gap;
  static const listHPad = AppUI.hPad;
  static const listVPad = AppUI.vGap;
}

@Deprecated('Use AppUI instead')
class JournalLayout {
  static const hPad = AppUI.hPad;
  static const vGap = AppUI.vGap;
  static const timeColW = AppUI.timeColW;
  static const timeDotGap = AppUI.timeDotGap;
  static const cardRadius = AppUI.cardRadius;
  static const cardElevation = AppUI.cardElevation;
  static const dotSize = AppUI.dotSize;
  static const timeColor = AppUI.timeColor;
  static const iconColor = AppUI.iconColor;
  static const dayCaption = AppUI.dayCaption;
}
