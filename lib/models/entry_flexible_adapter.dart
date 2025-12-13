// lib/models/entry_flexible_adapter.dart
// Универсальный адаптер: читает timestamp и в DateTime, и в int (сек/мс/мкс), и в String.
// Терпим к старым вариантам индексов (3 или 4) и к перестановке comment/mood.

import 'package:hive/hive.dart';
import 'entry.dart';

class EntryFlexibleAdapter extends TypeAdapter<Entry> {
  EntryFlexibleAdapter(this._typeId);
  final int _typeId;

  @override
  int get typeId => _typeId;

  bool _looksLikeEpochInt(int v) => v.abs() > 1000000000; // > 1e9 — явно не «120/80»

  DateTime _toDateTime(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is int) {
      // сек/мс эвристика: очень большие считаем мс, иначе секунды.
      if (raw > 100000000000) return DateTime.fromMillisecondsSinceEpoch(raw);
      return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    }
    if (raw is String) {
      final dt = DateTime.tryParse(raw);
      if (dt != null) return dt;
    }
    // На крайний случай — «сейчас», чтобы не падать.
    return DateTime.now();
  }

  int _toInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw') ?? 0;
  }

  dynamic _pickTimestamp(Map<int, dynamic> f) {
    // самые вероятные места
    if (f.containsKey(3)) {
      final v = f[3];
      if (v is DateTime || v is int || v is String) return v;
    }
    if (f.containsKey(4)) {
      final v = f[4];
      if (v is DateTime || v is int || v is String) return v;
    }
    // общий поиск по значениям
    for (final v in f.values) {
      if (v is DateTime) return v;
      if (v is int && _looksLikeEpochInt(v)) return v;
      if (v is String && DateTime.tryParse(v) != null) return v;
    }
    return null;
  }

  String? _pickComment(Map<int, dynamic> f) {
    // чаще всего 4 или 5
    final c4 = f[4];
    if (c4 is String) return c4;
    final c5 = f[5];
    if (c5 is String) return c5;
    // иначе — первая строка, которая не дата
    for (final v in f.values) {
      if (v is String && DateTime.tryParse(v) == null) {
        return v;
      }
    }
    return null;
  }

  int? _pickMood(Map<int, dynamic> f) {
    final m5 = f[5];
    if (m5 is num) return m5.toInt();
    final m6 = f[6];
    if (m6 is num) return m6.toInt();
    return null;
  }

  @override
  Entry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final tsRaw = _pickTimestamp(fields);
    final comment = _pickComment(fields);
    final mood = _pickMood(fields);

    return Entry(
      systolic: _toInt(fields[0]),
      diastolic: _toInt(fields[1]),
      pulse: _toInt(fields[2]),
      timestamp: _toDateTime(tsRaw),
      comment: comment,
      mood: mood,
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    // Пишем по актуальной схеме (индексы 0..5). Старые записи читаются гибко, новые — строго.
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.systolic)
      ..writeByte(1)..write(obj.diastolic)
      ..writeByte(2)..write(obj.pulse)
      ..writeByte(3)..write(obj.timestamp)
      ..writeByte(4)..write(obj.comment)
      ..writeByte(5)..write(obj.mood);
  }
}
