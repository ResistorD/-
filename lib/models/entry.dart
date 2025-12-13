// models/entry.dart — стабильная схема для Hive
import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;   // ВАЖНО: остаётся под индексом 0

  @HiveField(1)
  final int systolic;

  @HiveField(2)
  final int diastolic;

  @HiveField(3)
  final int? pulse;           // nullable, чтобы читать старые записи

  @HiveField(4)
  final String? comment;      // опционально

  @HiveField(5)
  final int? mood;            // опционально

  // ← НЕ const, потому что HiveObject имеет не-const super()
  Entry({
    required this.timestamp,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.comment,
    this.mood,
  });
}
