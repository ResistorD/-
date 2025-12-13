import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'prefs_service.dart';

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const _chId = 'bp_reminders';
  static const _chNm = 'Напоминания';
  static const _chDsc = 'Ежедневные напоминания измерить давление';

  static const _idMorning = 1001;
  static const _idEvening = 1002;
  static const _idExtraBase = 1100; // 1100, 1101, ...

  static bool _tzReady = false;

  static Future<void> init() async {
    // Таймзона
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      _tzReady = true;
    } catch (_) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<bool> ensurePermissions() async {
    if (Platform.isAndroid) {
      final and = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await and?.areNotificationsEnabled() ?? true;
    } else {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ??
          true;
    }
  }

  static Future<void> refreshDailyReminders() async {
    if (!_tzReady) return;
    await cancelDaily();

    if (!PrefsService.remindersEnabled) return;

    await _scheduleDaily(
      id: _idMorning,
      time: PrefsService.morningTime,
      title: 'Пора измерить давление',
      body: 'Ежедневное напоминание (утро).',
    );
    await _scheduleDaily(
      id: _idEvening,
      time: PrefsService.eveningTime,
      title: 'Пора измерить давление',
      body: 'Ежедневное напоминание (вечер).',
    );

    // extras
    final extras = PrefsService.extraTimes;
    for (var i = 0; i < extras.length; i++) {
      await _scheduleDaily(
        id: _idExtraBase + i,
        time: extras[i],
        title: 'Пора измерить давление',
        body: 'Ежедневное напоминание',
      );
    }
  }

  static Future<void> cancelDaily() async {
    await _plugin.cancel(_idMorning);
    await _plugin.cancel(_idEvening);
    for (var i = 0; i < 20; i++) {
      await _plugin.cancel(_idExtraBase + i); // с запасом
    }
  }

  static Future<void> _scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    final android = AndroidNotificationDetails(
      _chId,
      _chNm,
      channelDescription: _chDsc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(android: android, iOS: ios),
      // заменяем устаревший androidAllowWhileIdle:
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // ежедневно в то же время
    );
  }
}
