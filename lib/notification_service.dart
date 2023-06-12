import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    var androidDetails = AndroidNotificationDetails('channelId', 'channelName',
        'channelDescription', importance: Importance.max, priority: Priority.high);
    var iOSDetails = IOSNotificationDetails();
    var details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    var tz;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, tz.TZDateTime.from(scheduledDate, tz.local), details,
        androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}
