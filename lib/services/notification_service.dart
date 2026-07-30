import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../app_state.dart';

/// Schedules local notifications for the five daily prayers.
///
/// Notifications for today and tomorrow are (re)scheduled whenever the app
/// starts or relevant settings change, which keeps the pending count well
/// under iOS's 64-notification limit.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Base name of the bundled Athan audio.
  //  • Android: android/app/src/main/res/raw/athan.mp3  (referenced by name)
  //  • iOS:     add athan.aiff to the Runner target in Xcode
  // If the file is missing the OS quietly falls back to the default sound, so
  // the app still builds and runs without it.
  static const _androidAthanSound =
      RawResourceAndroidNotificationSound('athan');
  static const _iosAthanSound = 'athan.aiff';

  // Notification with the full Athan recitation. Android binds a channel's
  // sound at creation time, so this uses a distinct channel id from the
  // default-sound one below to guarantee the custom sound takes effect.
  static const NotificationDetails _athanSoundDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'athan_channel_sound',
      'Athan (with sound)',
      channelDescription: 'Prayer time notifications with the Athan recitation',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      sound: _androidAthanSound,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: false,
      sound: _iosAthanSound,
    ),
  );

  // Notification with the default system sound (Athan sound turned off).
  static const NotificationDetails _defaultSoundDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'athan_channel',
      'Athan',
      channelDescription: 'Prayer time notifications',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: false,
    ),
  );

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep the default (UTC) location; scheduling still works because we
      // convert from local DateTimes explicitly.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      ),
    );
  }

  static Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Cancels everything and schedules athan notifications for all prayers of
  /// today and tomorrow that are still in the future.
  static Future<void> rescheduleAthanNotifications(AppState state) async {
    await _plugin.cancelAll();
    if (!state.athanNotificationsEnabled) return;

    final details =
        state.athanSoundEnabled ? _athanSoundDetails : _defaultSoundDetails;

    final now = DateTime.now();
    var id = 0;
    for (var dayOffset = 0; dayOffset < 2; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final entries =
          state.prayerEntriesFor(date).where((e) => e.isObligatory);
      for (final entry in entries) {
        if (entry.time.isBefore(now)) continue;
        try {
          await _plugin.zonedSchedule(
            id: id++,
            title: '${entry.name} prayer time',
            body: "QalbCare: It's time for ${entry.name} in ${state.locationLabel}",
            scheduledDate: tz.TZDateTime.from(entry.time, tz.local),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } on UnimplementedError {
          // Scheduled notifications are only supported on Android/iOS;
          // desktop builds simply skip them.
          return;
        }
      }
    }
  }
}
