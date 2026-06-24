import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );
    
    await _notifications.initialize(settings);
    tz.initializeTimeZones();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'ledgr_reminders',
      'Bill Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const darwin = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: android,
      iOS: darwin,
    );
    
    await _notifications.show(id, title, body, details);
  }
}
