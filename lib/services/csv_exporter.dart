import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/entry.dart';
import 'storage_service.dart';

class CsvExporter {
  /// Возвращает полный путь к сохранённому CSV.
  static Future<String> exportAllEntries() async {
    final List<Entry> entries = StorageService.entriesBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final buf = StringBuffer()
      ..writeln('timestamp_iso;systolic;diastolic;pulse;comment');

    for (final e in entries) {
      final iso = e.timestamp.toIso8601String();
      final pulse = e.pulse?.toString() ?? '';
      final comment = (e.comment ?? '')
          .replaceAll('\n', ' ')
          .replaceAll(';', ',');
      buf.writeln('$iso;${e.systolic};${e.diastolic};$pulse;$comment');
    }

    final baseDir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final fileName =
        'pressure_diary_${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';

    final file = File('${baseDir.path}/$fileName');
    await file.writeAsString(buf.toString());
    return file.path;
  }
}
