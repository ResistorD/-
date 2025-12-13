import 'dart:io';
import 'package:flutter/services.dart';                 // Clipboard
import 'package:path_provider/path_provider.dart';       // getTemporaryDirectory
import 'package:share_plus/share_plus.dart';             // Share.shareXFiles

import '../models/entry.dart';
import 'storage_service.dart';

class ExportService {
  // Используем ; как в вашем обработчике
  static const String _delimiter = ';';

  static Future<void> exportCsv() async {
    // 1) Собираем строки
    final box = StorageService.entriesBox;
    final entries = box.values.cast<Entry>().toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final buf = StringBuffer();
    buf.writeln('timestamp${_delimiter}systolic${_delimiter}diastolic${_delimiter}pulse${_delimiter}comment');

    for (final e in entries) {
      final ts = e.timestamp.toIso8601String();
      final pulse = e.pulse?.toString() ?? '';
      final comment = _sanitize(e.comment ?? '');
      buf.writeln([
        ts,
        e.systolic,
        e.diastolic,
        pulse,
        comment,
      ].join(_delimiter));
    }

    // 2) Пишем во временный файл
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pressure_diary_export.csv');
    await file.writeAsString(buf.toString(), flush: true);

    // 3) Пробуем системный share; если нечем поделиться — копируем CSV в буфер
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Экспорт дневника давления (CSV)',
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: buf.toString()));
    }
  }

  static String _sanitize(String s) {
    // заменяем разделитель на запятую, убираем переносы строк, экранируем кавычки
    final replaced = s.replaceAll(_delimiter, ',').replaceAll('\n', ' ');
    return replaced.replaceAll('"', '""');
  }
}
