import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:sajda_app/models/namoz_time_model.dart';

/// Namoz vaqtlari uchun mahalliy (local) bildirishnomalarni boshqaradi.
///
/// Har 5 vaqt namozda ("Bomdod, Peshin, Asr, Shom, Xufton") o'sha vaqt
/// kirganda ovozli bildirishnoma yuboradi. Bildirishnomalar kunma-kun
/// takrorlanadi va namoz vaqtlari yangilanganда qayta rejalashtiriladi.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'namoz_vaqtlari_channel';
  static const String _channelName = 'Namoz vaqtlari';
  static const String _channelDesc =
      'Har namoz vaqti kirganda eslatuvchi bildirishnomalar';

  static const String _prefsKey = 'notifications_enabled';

  bool _initialized = false;

  /// Bildirishnomalar yoqilganmi? (SharedPreferences'dan)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Standart holatda yoqilgan bo'lsin.
    return prefs.getBool(_prefsKey) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  /// Plugin va timezone'ni ishga tushiradi. main()'da chaqiriladi.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
    } catch (_) {
      // Zona topilmasa — standart holatда qoldiramiz.
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Android kanalini oldindan yaratamiz.
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialized = true;
  }

  /// Bildirishnoma ruxsatlarini so'raydi (Android 13+ va iOS).
  Future<bool> requestPermissions() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;
    if (androidImpl != null) {
      granted = await androidImpl.requestNotificationsPermission() ?? true;
      // Aniq vaqtli alarmlar uchun ruxsat (Android 12+).
      await androidImpl.requestExactAlarmsPermission();
    }
    if (iosImpl != null) {
      granted = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }
    return granted;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  /// Namoz vaqtlaridan kelib chiqib 5 ta kunlik bildirishnomani
  /// (bomdod, peshin, asr, shom, xufton) qayta rejalashtiradi.
  Future<void> schedulePrayerNotifications(NamozTime time) async {
    if (!_initialized) await init();

    // Avval eski rejalarni tozalaymiz.
    await cancelAll();

    if (!await isEnabled()) return;

    final entries = <_PrayerEntry>[
      _PrayerEntry(1, 'Bomdod', time.times.bomdod),
      _PrayerEntry(2, 'Peshin', time.times.peshin),
      _PrayerEntry(3, 'Asr', time.times.asr),
      _PrayerEntry(4, 'Shom', time.times.shom),
      _PrayerEntry(5, 'Xufton', time.times.xufton),
    ];

    for (final e in entries) {
      final hm = _parseHm(e.time);
      if (hm == null) continue;
      await _scheduleDaily(
        id: e.id,
        title: '${e.name} vaqti kirdi',
        body: '${e.name} namozini o‘qishni unutmang. Alloh qabul qilsin.',
        hour: hm.$1,
        minute: hm.$2,
      );
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// "HH:MM" (yoki "HH:MM:SS") stringdan soat/daqiqani ajratadi.
  (int, int)? _parseHm(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final parts = t.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return (h, m);
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Sozlamalardan yoqib/o'chirilganда chaqiriladi.
  Future<void> applyEnabled(bool enabled, {NamozTime? time}) async {
    await setEnabled(enabled);
    if (!enabled) {
      await cancelAll();
    } else if (time != null) {
      await requestPermissions();
      await schedulePrayerNotifications(time);
    }
  }

  /// Test uchun: bir necha soniyadan keyin bildirishnoma yuboradi.
  Future<void> showTestNotification() async {
    if (!_initialized) await init();
    await _plugin.show(
      999,
      'Sajda',
      'Bildirishnomalar yoqildi ✅',
      _details,
    );
  }
}

class _PrayerEntry {
  final int id;
  final String name;
  final String time;
  const _PrayerEntry(this.id, this.name, this.time);
}
