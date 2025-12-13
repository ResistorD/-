import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/prefs_service.dart';
import '../services/notifications_service.dart';
import '../services/export_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _reminders;
  late TimeOfDay _morning;
  late TimeOfDay _evening;
  late String _theme;
  late List<TimeOfDay> _extras; // дополнительные времена

  @override
  void initState() {
    super.initState();
    _reminders = PrefsService.remindersEnabled;
    _morning   = PrefsService.morningTime;
    _evening   = PrefsService.eveningTime;
    _theme     = PrefsService.themeMode;
    _extras    = List.of(PrefsService.extraTimes); // [] если нет
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  InputDecoration _pill(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _pickFixedTime({required bool morning}) async {
    final t = await showTimePicker(
      context: context,
      initialTime: morning ? _morning : _evening,
    );
    if (t == null) return;

    if (morning) {
      _morning = t;
      await PrefsService.setMorningTime(t);
    } else {
      _evening = t;
      await PrefsService.setEveningTime(t);
    }
    setState(() {});
    if (_reminders) await NotificationsService.refreshDailyReminders();
  }

  Future<void> _pickExtraTime(int i) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _extras[i],
    );
    if (t == null) return;
    _extras[i] = t;
    setState(() {});
    await PrefsService.setExtraTimes(_extras);
    if (_reminders) await NotificationsService.refreshDailyReminders();
  }

  Future<void> _addExtraTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null) return;
    _extras.add(t);
    setState(() {});
    await PrefsService.setExtraTimes(_extras);
    if (_reminders) await NotificationsService.refreshDailyReminders();
  }

  Future<void> _removeExtraTime(int i) async {
    _extras.removeAt(i);
    setState(() {});
    await PrefsService.setExtraTimes(_extras);
    if (_reminders) await NotificationsService.refreshDailyReminders();
  }

  Future<void> _writeToDev() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@yourdomain.tld',
      query: 'subject=${Uri.encodeComponent('Обратная связь: Дневник давления')}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _rateApp() async {
    final info = await PackageInfo.fromPlatform();
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=${info.packageName}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs   = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // или ext?.bgLight
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // --- Напоминания ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Напоминания',
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Switch(
                        value: _reminders,
                        onChanged: (v) async {
                          setState(() => _reminders = v);
                          await PrefsService.setRemindersEnabled(v);
                          if (v) {
                            final ok = await NotificationsService.ensurePermissions();
                            if (!ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Разрешите уведомления в настройках системы'),
                                ),
                              );
                            }
                            await NotificationsService.refreshDailyReminders();
                          } else {
                            await NotificationsService.cancelDaily();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _reminders ? () => _pickFixedTime(morning: true) : null,
                          child: InputDecorator(
                            decoration: _pill(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Утро'),
                                Text(_hhmm(_morning),
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _reminders ? () => _pickFixedTime(morning: false) : null,
                          child: InputDecorator(
                            decoration: _pill(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Вечер'),
                                Text(_hhmm(_evening),
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Дополнительные времена (редактирование/удаление)
                  for (int i = 0; i < _extras.length; i++) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _reminders ? () => _pickExtraTime(i) : null,
                            onLongPress: () => _removeExtraTime(i),
                            child: InputDecorator(
                              decoration: _pill(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Доп.'),
                                  Text(_hhmm(_extras[i]),
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()), // выравнивание
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _reminders ? _addExtraTime : null,
                      child: const Text('+ ДОБАВИТЬ ВРЕМЯ'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Тема ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тема',
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _theme,
                    isExpanded: true,
                    decoration: _pill(context),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('Системная')),
                      DropdownMenuItem(value: 'light',  child: Text('Светлая')),
                      DropdownMenuItem(value: 'dark',   child: Text('Тёмная')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() => _theme = v);
                      await PrefsService.setThemeMode(v);
                      // Применяется сразу, т.к. MaterialApp слушает PrefsService.changes
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Утилиты ---
          _BigButton(
            label: 'Сбросить данные',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Сбросить все данные?'),
                  content: const Text('Это удалит все записи. Действие необратимо.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сбросить')),
                  ],
                ),
              );
              if (ok == true) {
                await StorageService.entriesBox.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные удалены')),
                  );
                }
              }
            },
          ),

          _BigButton(
            label: 'Экспорт данных (CSV)',
            onPressed: () async {
              try {
                await ExportService.exportCsv();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Не удалось экспортировать: $e')),
                );
              }
            },
          ),
          _BigButton(label: 'Написать разработчику', onPressed: _writeToDev),
          _BigButton(label: 'Оценить приложение', onPressed: _rateApp),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'Версия 1.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}
