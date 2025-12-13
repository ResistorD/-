// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryAdapter extends TypeAdapter<Entry> {
  @override
  final int typeId = 0;

  DateTime _toDateTime(dynamic v) {
    if (v is DateTime) return v;
    if (v is int) {
      if (v > 2000000000000000) return DateTime.fromMicrosecondsSinceEpoch(v);
      if (v > 2000000000 && v <= 2000000000000) {
        // секунды с эпохи
        return DateTime.fromMillisecondsSinceEpoch(v * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    if (v is String) {
      final n = int.tryParse(v);
      if (n != null) return _toDateTime(n);
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    // запасной вариант
    return DateTime.now();
  }

  @override
  Entry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    bool looksLikeDate(dynamic v) =>
        v is DateTime || v is int || v is String;

    // НОВАЯ схема: 0 = timestamp, 1=sys,2=dia,3=pulse,4=comment,5=mood
    return Entry(
      timestamp: _toDateTime(fields[0]),
      systolic: (fields[1] as num).toInt(),
      diastolic: (fields[2] as num).toInt(),
      pulse: (fields[3] is num) ? (fields[3] as num).toInt() : null,
      comment: (fields[4] is String) ? fields[4] as String : null,
      mood: (fields[5] is num) ? (fields[5] as num).toInt() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    // Пишем в НОВОЙ схеме
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.systolic)
      ..writeByte(2)
      ..write(obj.diastolic)
      ..writeByte(3)
      ..write(obj.pulse)
      ..writeByte(4)
      ..write(obj.comment)
      ..writeByte(5)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EntryAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
