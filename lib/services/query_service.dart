// lib/services/query_service.dart
import '../models/entry.dart';

/// Период для графика/фильтров
enum Period { last7, last30, last90, all }

extension PeriodX on Period {
  String get label {
    switch (this) {
      case Period.last7:  return '7д';
      case Period.last30: return '30д';
      case Period.last90: return '90д';
      case Period.all:    return 'Все';
    }
  }

  Duration? get duration {
    switch (this) {
      case Period.last7:  return const Duration(days: 7);
      case Period.last30: return const Duration(days: 30);
      case Period.last90: return const Duration(days: 90);
      case Period.all:    return null;
    }
  }
}

/// Универсальные утилиты выборки/сортировки
class QueryService {
  /// Возвращает копию [entries], отфильтрованную по периоду и
  /// отсортированную по возрастанию времени (удобно для графика).
  static List<Entry> forChart(List<Entry> entries, Period p) {
    final filtered = filterByPeriod(entries, p);
    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  /// Фильтрует по периоду. Если Period.all — вернёт копию исходного.
  static List<Entry> filterByPeriod(List<Entry> entries, Period p) {
    final src = List<Entry>.from(entries);
    final dur = p.duration;
    if (dur == null) {
      // Все
      return src;
    }
    final cutoff = DateTime.now().subtract(dur);
    return src.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  /// Простой min/max для осей графика
  static ({int minDia, int maxSys}) findYBounds(List<Entry> data) {
    if (data.isEmpty) return (minDia: 40, maxSys: 200);
    var minDia = data.first.diastolic;
    var maxSys = data.first.systolic;
    for (final e in data) {
      if (e.diastolic < minDia) minDia = e.diastolic;
      if (e.systolic > maxSys) maxSys = e.systolic;
    }
    // небольшой «пэддинг»
    minDia = (minDia - 10).clamp(40, 200);
    maxSys = (maxSys + 10).clamp(120, 280);
    return (minDia: minDia, maxSys: maxSys);
  }
}