import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static const int _morningId = 1;
  static const int _eveningId = 2;

  static const _channel = MethodChannel('com.example.aura_tracker/battery');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(Map<String, int> times) async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // Fall back to UTC if device timezone detection fails
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await reschedule(
      morningHour: times['morningHour']!,
      morningMinute: times['morningMin']!,
      eveningHour: times['eveningHour']!,
      eveningMinute: times['eveningMin']!,
    );
  }

  /// Returns true if the app is exempt from battery optimizations.
  Future<bool> isBatteryOptimizationExempt() async {
    try {
      final result = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } on MissingPluginException {
      return true; // non-Android platform
    } catch (_) {
      return false;
    }
  }

  /// Opens the system dialog asking the user to exempt this app from battery
  /// optimization. Does nothing if already exempt.
  Future<void> requestBatteryOptimizationExemption() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }

  Future<void> reschedule({
    required int morningHour,
    required int morningMinute,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    await _plugin.cancel(_morningId);
    await _plugin.cancel(_eveningId);
    await _scheduleDaily(
      id: _morningId,
      hour: morningHour,
      minute: morningMinute,
      title: 'Good morning ☀️',
      body: 'Log your sleep and start the day right.',
    );
    await _scheduleDaily(
      id: _eveningId,
      hour: eveningHour,
      minute: eveningMinute,
      title: 'Evening check-in 🌙',
      body: 'How was your day? Log stress, hydration and more.',
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'aura_daily',
      'Daily Check-ins',
      channelDescription: 'Morning and evening check-in reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
