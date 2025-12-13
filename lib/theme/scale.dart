import 'package:flutter/material.dart';

double _clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);

/// Базовая ширина макета из Figma
const double _designWidth = 360;

/// масштаб по ширине экрана (в разумных пределах)
double _wScale(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return _clamp(w / _designWidth, 0.90, 3.0);
}

/// dp для отступов/размеров
double dp(BuildContext context, double value) => value * _wScale(context);

/// sp для текста (НЕ уважает системный размер шрифта)
double sp(BuildContext context, double value) => value * _wScale(context);

// Если когда-нибудь понадобится «уважать систему», можно завести spSys:
// double spSys(BuildContext c, double v) =>
//   MediaQuery.textScalerOf(c).scale(v * _wScale(c));
