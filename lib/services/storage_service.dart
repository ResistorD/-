import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';

class StorageService {
  static const String _entriesBoxName = 'entries';

  /// Вызывай один раз при старте (в main) до работы с боксом.
  static Future<void> init() async {
    // Инициализация Hive для Flutter (важно ДО openBox)
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(EntryAdapter().typeId)) {
      Hive.registerAdapter(EntryAdapter());
    }
    if (!Hive.isBoxOpen(_entriesBoxName)) {
      await Hive.openBox<Entry>(_entriesBoxName);
    }
  }

  // --------- Back-compat (для существующего кода) ---------

  /// Синхронный доступ к боксу. Предполагает, что [init] уже вызывали.
  static Box<Entry> get entriesBox {
    if (!Hive.isBoxOpen(_entriesBoxName)) {
      throw HiveError(
        'Box "$_entriesBoxName" не открыт. Вызови StorageService.init() при старте приложения.',
      );
    }
    return Hive.box<Entry>(_entriesBoxName);
  }

  /// Удобно для ValueListenableBuilder: StorageService.entriesListenable
  static ValueListenable<Box<Entry>> get entriesListenable =>
      entriesBox.listenable();

  // --------- Безопасный доступ (внутренние и новые вызовы) ---------

  static Future<Box<Entry>> _box() async {
    if (!Hive.isBoxOpen(_entriesBoxName)) {
      await Hive.openBox<Entry>(_entriesBoxName);
    }
    return Hive.box<Entry>(_entriesBoxName);
  }

  static Future<List<Entry>> getAllEntries() async {
    final box = await _box();
    return box.values.toList();
  }

  static Future<void> addEntry(Entry e) async {
    final box = await _box();
    await box.add(e);
  }

  static Future<void> clearAllEntries() async {
    final box = await _box();
    await box.clear();
  }

  static Future<int> count() async {
    final box = await _box();
    return box.length;
  }
}