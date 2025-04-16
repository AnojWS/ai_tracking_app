import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannelHelper {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> createNotificationChannel({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final androidNotificationPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidNotificationPlugin != null) {
      var androidNotificationChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: importance,
        playSound: true,
      );

      await androidNotificationPlugin.createNotificationChannel(
        androidNotificationChannel,
      );
    }
  }
}
