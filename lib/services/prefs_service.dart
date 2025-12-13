import 'package:flutter/material.dart' show TimeOfDay, ValueNotifier;
import 'package:hive_flutter/hive_flutter.dart';

class PrefsKeys {
  // Профиль
  static const name   = 'name';
  static const gender = 'gender'; // 'm' | 'f'
  static const birth  = 'birth';  // ISO-строка или null

  // Нормы
  static const targetSys   = 'target_sys'; // верхняя «норма»
  static const targetDia   = 'target_dia'; // нижняя «норма»
  static const lowerSys    = 'lower_sys';  // нижняя граница допустимого (для синей точки)
  static const lowerDia    = 'lower_dia';

  // Напоминания
  static const remindEnabled = 'remind_enabled';
  static const timeMorning   = 'remind_time_morning'; // int minutes
  static const timeEvening   = 'remind_time_evening'; // int minutes
  static const timeExtras    = 'remind_time_extras';  // List<int> minutes

  // Тема
  static const themeMode = 'theme_mode'; // 'system'|'light'|'dark'

  // Диапазоны экранов
  static const journalRange = 'journal_range'; // 0..3
  static const chartsRange  = 'charts_range';  // 0..3
}

class PrefsService {
  static Box<dynamic>? _box;

  // Глобальный нотифаер — используем только для ТЕМЫ.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static void _notify() => changes.value++;

  static Future<void> init() async {
    if (!Hive.isBoxOpen('prefs')) {
      _box = await Hive.openBox<dynamic>('prefs');
    } else {
      _box = Hive.box<dynamic>('prefs');
    }
  }

  static Future<void> _ensure() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }

  // ---- утилиты: TimeOfDay <-> minutes
  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  static TimeOfDay _fromMinutes(int m) => TimeOfDay(hour: m ~/ 60, minute: m % 60);

  // ---------------- Профиль ----------------
  static String get name => _box?.get(PrefsKeys.name, defaultValue: '') ?? '';
  static Future<void> setName(String v) async {
    await _ensure();
    await _box!.put(PrefsKeys.name, v);
  }

  static String get gender => _box?.get(PrefsKeys.gender, defaultValue: 'm') ?? 'm';
  static Future<void> setGender(String v) async {
    await _ensure();
    await _box!.put(PrefsKeys.gender, (v == 'f') ? 'f' : 'm');
  }

  static DateTime? get birth {
    final s = _box?.get(PrefsKeys.birth) as String?;
    return s == null ? null : DateTime.tryParse(s);
  }
  static Future<void> setBirth(DateTime? d) async {
    await _ensure();
    if (d == null) {
      await _box!.delete(PrefsKeys.birth);
    } else {
      await _box!.put(PrefsKeys.birth, d.toIso8601String());
    }
  }

  // ---------------- Нормы давления ----------------
  static int get targetSys => _box?.get(PrefsKeys.targetSys, defaultValue: 120) ?? 120;
  static int get targetDia => _box?.get(PrefsKeys.targetDia, defaultValue: 80)  ?? 80;

  static Future<void> setTargetSys(int v) async {
    await _ensure();
    await _box!.put(PrefsKeys.targetSys, v);
  }
  static Future<void> setTargetDia(int v) async {
    await _ensure();
    await _box!.put(PrefsKeys.targetDia, v);
  }

  /// Верхняя «норма» как record для удобства (используется в журнале/графиках).
  static ({int sys,int dia}) get upperNorm => (sys: targetSys, dia: targetDia);

  /// Нижняя граница — по умолчанию 90/60, можно настроить (если используете синюю зону/точку).
  static ({int sys,int dia}) get lowerNorm => (
  sys: _box?.get(PrefsKeys.lowerSys, defaultValue: 100) ?? 100,
  dia: _box?.get(PrefsKeys.lowerDia, defaultValue: 65) ?? 65,
  );
  static Future<void> setLowerNorm({required int sys, required int dia}) async {
    await _ensure();
    await _box!.put(PrefsKeys.lowerSys, sys);
    await _box!.put(PrefsKeys.lowerDia, dia);
  }

  /// Совместимый метод, если где-то вызывается setUpperNorm(...)
  static Future<void> setUpperNorm({required int sys, required int dia}) async {
    await setTargetSys(sys);
    await setTargetDia(dia);
  }

  // ---------------- Напоминания ----------------
  static bool get remindersEnabled => _box?.get(PrefsKeys.remindEnabled, defaultValue: false) ?? false;
  static Future<void> setRemindersEnabled(bool v) async {
    await _ensure();
    await _box!.put(PrefsKeys.remindEnabled, v);
  }

  static TimeOfDay get morningTime {
    final m = _box?.get(PrefsKeys.timeMorning) as int?;
    return _fromMinutes(m ?? _toMinutes(const TimeOfDay(hour: 8, minute: 0)));
  }
  static Future<void> setMorningTime(TimeOfDay t) async {
    await _ensure();
    await _box!.put(PrefsKeys.timeMorning, _toMinutes(t));
  }

  static TimeOfDay get eveningTime {
    final m = _box?.get(PrefsKeys.timeEvening) as int?;
    return _fromMinutes(m ?? _toMinutes(const TimeOfDay(hour: 20, minute: 0)));
  }
  static Future<void> setEveningTime(TimeOfDay t) async {
    await _ensure();
    await _box!.put(PrefsKeys.timeEvening, _toMinutes(t));
  }

  static List<TimeOfDay> get extraTimes {
    final raw = (_box?.get(PrefsKeys.timeExtras) as List?)?.cast<int>() ?? const <int>[];
    return raw.map(_fromMinutes).toList();
  }
  static Future<void> setExtraTimes(List<TimeOfDay> list) async {
    await _ensure();
    final raw = list.map(_toMinutes).toList();
    await _box!.put(PrefsKeys.timeExtras, raw);
  }

  // ---------------- Тема ----------------
  /// 'system' | 'light' | 'dark'
  static String get themeMode => _box?.get(PrefsKeys.themeMode, defaultValue: 'system') ?? 'system';
  static Future<void> setThemeMode(String mode) async {
    await _ensure();
    final m = (mode == 'light' || mode == 'dark') ? mode : 'system';
    await _box!.put(PrefsKeys.themeMode, m);
    _notify(); // только тут — чтобы MaterialApp пересобрал тему
  }

  // ---------------- Диапазоны экранов ----------------
  static int get journalRange => _box?.get(PrefsKeys.journalRange, defaultValue: 0) ?? 0;
  static Future<void> setJournalRange(int idx) async {
    await _ensure();
    await _box!.put(PrefsKeys.journalRange, idx);
  }

  static int get chartsRange => _box?.get(PrefsKeys.chartsRange, defaultValue: 0) ?? 0;
  static Future<void> setChartsRange(int idx) async {
    await _ensure();
    await _box!.put(PrefsKeys.chartsRange, idx);
  }
}
