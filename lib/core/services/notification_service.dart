import 'dart:developer';

import 'package:ai_tracking_app/core/constants/app_constnats.dart';
import 'package:ai_tracking_app/core/helpers/notification_channel_helper.dart';
import 'package:ai_tracking_app/core/services/firebase_service.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.data}');
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await FirebaseService.init();
  await NotificationService.instance.setupNotification();
  await NotificationService.instance.showLocalNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationService.instance.onSelectNotification(response.payload);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _permissionsGranted = false;
  bool _pluginInitialized = false;

  Future<void> initialize() async {
    // Initialize Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Request permission for notifications
    await _requestPermission();
    // Setup notification handler
    await _setupNotificationHandler();

    // get the token for the device
    final String? token = await _messaging.getToken();
    log('Firebase Messaging Token: $token');
    // Optionally, you can send this token to your server for push notifications
  }

  Future<void> _requestPermission() async {
    if (_permissionsGranted) return;
    // Request notification permissions.
    final permission = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      carPlay: false,
      criticalAlert: false,
      announcement: false,
    );

    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission for notifications');
      _permissionsGranted = true;
    } else if (permission.authorizationStatus == AuthorizationStatus.denied) {
      log('User denied permission for notifications');
    } else if (permission.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission for notifications');
    } else {
      log('Notification permission status: ${permission.authorizationStatus}');
    }
  }

  Future<void> setupNotification() async {
    if (_pluginInitialized) return;

    //create nitificatiob chanel setup
    await NotificationChannelHelper.createNotificationChannel(
      channelId: notificationChannelId,
      channelName: notificationChannelName,
      channelDescription: notificationChannelDescription,
    );

    // Initialize Flutter Local Notifications.
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _pluginInitialized = true;
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle notification tap (navigate as needed)
    debugPrint('Notification tapped with payload: $payload');
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    // Check if the message has a notification payload.
    // If it does, the OS may already be displaying it.
    if (message.notification != null) {
      log(
        "Message contains a notification payload; skipping local notification.",
      );
      return;
    }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            notificationChannelId,
            notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher",
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data.toString(),
      );
    }
  }

  /// Schedules a local notification at a specific DateTime.
  Future<void> scheduleNotification({required GoalModel goal}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          notificationChannelId,
          notificationChannelName,
          channelDescription: notificationChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      (goal.id).hashCode,
      goal.title,
      'Your goal "${goal.title}" is due now!',
      tz.TZDateTime.from(goal.deadline ?? DateTime.now(), tz.local),
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Notification handler for when the app is in the background or terminated.
  Future<void> _setupNotificationHandler() async {
    //forground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('Received a message while in the foreground: ${message.toMap()}');
      await showLocalNotification(message);
    });
    //background message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification clicked! Message: ${message.data}');
      _handleBackgroundMessage(message);
    });
    //terminated message handler
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        log('App was opened from a terminated state: ${message.data}');
        _handleBackgroundMessage(message);
      }
    });
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    showLocalNotification(message);
    if (message.data['type'] == 'goal') {
      log('Background message: ${message.data}');
      // open goal screen or perform any action based on the message data for now just show notification
    }
  }
}
