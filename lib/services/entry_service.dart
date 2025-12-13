// services/entry_service.dart — сервис для управления записями Entry через Hive
import 'package:hive/hive.dart';
import '../models/entry.dart';

class EntryService {
  static const String _boxName = 'entries';

  Future<void> addEntry(Entry entry) async {
    final box = await Hive.openBox<Entry>(_boxName);
    await box.add(entry);
  }

  Future<List<Entry>> getEntries() async {
    final box = await Hive.openBox<Entry>(_boxName);
    return box.values.toList();
  }

  Future<void> deleteEntry(Entry entry) async {
    await entry.delete();
  }

  Future<void> clearAll() async {
    final box = await Hive.openBox<Entry>(_boxName);
    await box.clear();
  }
}
