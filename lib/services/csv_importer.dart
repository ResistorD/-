import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/entry.dart';
import '../services/storage_service.dart';

class CsvImportResult {
  final int total;
  final int imported;
  final int skippedDuplicates;
  final int skippedInvalid;

  const CsvImportResult({
    required this.total,
    required this.imported,
    required this.skippedDuplicates,
    required this.skippedInvalid,
  });
}

class CsvImporter {
  /// Импортирует записи из текста CSV.
  /// Поддерживает разделители: `,` `;` `\t`.
  /// Заголовок может быть: timestamp,systolic,diastolic,pulse,comment
  static Future<CsvImportResult> importFromText(String text) async {
    final lines = const LineSplitter().convert(text).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return const CsvImportResult(total: 0, imported: 0, skippedDuplicates: 0, skippedInvalid: 0);
    }

    // Определяем разделитель
    String pickDelimiter(String s) {
      final counts = {
        ',': s.split(',').length,
        ';': s.split(';').length,
        '\t': s.split('\t').length,
      };
      return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    final delim = pickDelimiter(lines.first);
    int total = 0, imported = 0, dup = 0, bad = 0;

    // Проверим, есть ли header
    bool looksLikeHeader(String s) {
      final lower = s.toLowerCase();
      return lower.contains('syst') || lower.contains('dias') || lower.contains('pulse') || lower.contains('timestamp');
    }

    int startIndex = 0;
    if (looksLikeHeader(lines[0])) startIndex = 1;

    // соберём текущие ключи для детекта дублей: "ts|s|d|p"
    final box = StorageService.entriesBox;
    final existing = <String>{};
    for (final e in box.values) {
      existing.add(_key(e.timestamp, e.systolic, e.diastolic, e.pulse));
    }

    for (var i = startIndex; i < lines.length; i++) {
      total++;
      final row = _splitSmart(lines[i], delim);
      if (row.length < 3) { bad++; continue; }

      DateTime? ts = _parseTs(row[0].trim());
      int? s = _toInt(row[1]);
      int? d = _toInt(row[2]);
      int? p = row.length >= 4 ? _toInt(row[3]) : null;
      String? c = row.length >= 5 ? _unquote(row[4]) : null;

      if (ts == null || s == null || d == null) { bad++; continue; }

      final k = _key(ts, s, d, p);
      if (existing.contains(k)) { dup++; continue; }

      await StorageService.addEntry(
        Entry(
          systolic: s,
          diastolic: d,
          pulse: p,
          comment: (c == null || c.isEmpty) ? null : c,
          timestamp: ts,
        ),
      );
      existing.add(k);
      imported++;
    }

    return CsvImportResult(
      total: total,
      imported: imported,
      skippedDuplicates: dup,
      skippedInvalid: bad,
    );
  }

  static List<String> _splitSmart(String line, String delim) {
    // Простейший CSV сплит с учётом кавычек
    final out = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        // удвоенная кавычка внутри quoted
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"'); i++; continue;
        }
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && line.substring(i).startsWith(delim)) {
        out.add(buf.toString());
        buf.clear();
        i += delim.length - 1;
        continue;
      }
      buf.write(ch);
    }
    out.add(buf.toString());
    return out;
  }

  static String _unquote(String s) {
    var v = s.trim();
    if (v.startsWith('"') && v.endsWith('"') && v.length >= 2) {
      v = v.substring(1, v.length - 1).replaceAll('""', '"');
    }
    return v;
  }

  static int? _toInt(String s) {
    final v = s.trim();
    if (v.isEmpty) return null;
    return int.tryParse(v);
  }

  static String _key(DateTime ts, int s, int d, int? p) =>
      '${ts.millisecondsSinceEpoch}|$s|$d|${p ?? 0}';

  static DateTime? _parseTs(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;
    // millis
    final asInt = int.tryParse(v);
    if (asInt != null) {
      try {
        // если похоже на секунды — умножим
        if (asInt < 10 * 365 * 24 * 3600) {
          return DateTime.fromMillisecondsSinceEpoch(asInt * 1000, isUtc: false);
        }
        return DateTime.fromMillisecondsSinceEpoch(asInt, isUtc: false);
      } catch (_) {}
    }
    // ISO8601
    try { return DateTime.parse(v); } catch (_) {}
    // dd.MM.yyyy HH:mm
    final dm = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})(?:\s+(\d{1,2}):(\d{2}))?$').firstMatch(v);
    if (dm != null) {
      final d = int.parse(dm.group(1)!);
      final m = int.parse(dm.group(2)!);
      final y = int.parse(dm.group(3)!);
      final hh = int.tryParse(dm.group(4) ?? '') ?? 0;
      final mm = int.tryParse(dm.group(5) ?? '') ?? 0;
      return DateTime(y, m, d, hh, mm);
    }
    // yyyy-MM-dd HH:mm
    final ym = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{2}))?$').firstMatch(v);
    if (ym != null) {
      final y = int.parse(ym.group(1)!);
      final m = int.parse(ym.group(2)!);
      final d = int.parse(ym.group(3)!);
      final hh = int.tryParse(ym.group(4) ?? '') ?? 0;
      final mm = int.tryParse(ym.group(5) ?? '') ?? 0;
      return DateTime(y, m, d, hh, mm);
    }
    return null;
  }
}
