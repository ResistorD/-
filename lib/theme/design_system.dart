// lib/theme/design_system.dart
import 'package:flutter/material.dart';

/// Базовая сетка 8pt
class DS {
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s28 = 28.0;
  static const s32 = 32.0;

  // Радиусы
  static const r8  = Radius.circular(8);
  static const r12 = Radius.circular(12);
  static const r16 = Radius.circular(16);
  static const r20 = Radius.circular(20);

  // Кроуглые формы
  static final br12 = BorderRadius.circular(12);
  static final br16 = BorderRadius.circular(16);
  static final br20 = BorderRadius.circular(20);

  // Тени (как в макете)
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(blurRadius: 16, offset: Offset(0, 8), color: Color(0x1A000000)),
  ];
}
