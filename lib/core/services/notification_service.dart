import 'dart:convert';
import 'dart:developer';

import 'package:ai_tracking_app/core/constants/app_constnats.dart';
import 'package:ai_tracking_app/core/di/dependency_injection.dart';
import 'package:ai_tracking_app/core/helpers/notification_channel_helper.dart';
import 'package:ai_tracking_app/core/network/api_client.dart';
import 'package:ai_tracking_app/core/services/firebase_service.dart';
import 'package:ai_tracking_app/features/auth/data/repositories/auth_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Existing initialization code...
  log('Handling a background message: ${message.messageId}');
  log(
    'Message Notification Payload: ${message.notification != null ? message.notification!.toMap() : 'null'}',
  );
  log('Message Data Payload: ${message.data}');
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await FirebaseService.init(); // Ensure Firebase is init

  // --- Check if OS will already handle display ---
  if (message.notification != null) {
    log(
      "Notification payload exists. OS will likely handle display. Skipping manual local notification in background handler.",
    );
    // You could still perform background data processing here if needed,
    // but don't call showDataNotification.
  } else {
    // --- Only show manually if it's a DATA-ONLY message ---
    log(
      "Notification payload is null. Manually showing notification from data payload.",
    );
    // Ensure local notifications are set up before showing
    await NotificationService.instance.setupNotification();
    await NotificationService.instance.showDataNotification(message.data);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationService.instance.onSelectNotification(response.payload);
}

class NotificationService {
  NotificationService._(); // Keep private constructor if using instance getter
  static final NotificationService instance = NotificationService._();

  // --- Dependencies (fetched via GetIt) ---
  // These allow calling backend from NotificationService if needed,
  // but it's generally better to do it from AuthBloc or Repositories.
  AuthRepository get _authRepository => getIt<AuthRepository>();
  ApiClient get _apiClient => getIt<ApiClient>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _permissionsGranted = false;
  bool _pluginInitialized = false;
  String? _currentToken; // Store current token

  Future<void> initialize() async {
    // Initialize timezone data.
    tz.initializeTimeZones();
    // Initialize Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Request permission for notifications
    await _requestPermission();
    // Setup notification handler
    await _setupNotificationHandler();

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    // Get initial token (might be null if permissions denied)
    await _getTokenAndRegister();
  }

  Future<void> _getTokenAndRegister({bool forceRefresh = false}) async {
    if (!_permissionsGranted) {
      log("Notification permissions not granted. Cannot get/register token.");
      return;
    }
    // Get user ID - THIS IS CRUCIAL. Only proceed if user is logged in.
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      log("User not logged in. Skipping token registration.");
      // Token will be registered when AuthBloc signals login.
      return;
    }

    try {
      if (forceRefresh) {
        await _messaging.deleteToken(); // Delete token to force refresh
        log("Forcing FCM token refresh...");
      }
      _currentToken = await _messaging.getToken();
      log('Firebase Messaging Token: $_currentToken');

      if (_currentToken != null) {
        // Get timezone
        final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
        log("Device Timezone: $currentTimeZone");

        // Register with backend
        bool success = await _apiClient.registerToken(
          token: _currentToken!,
          userId: userId,
          timezone: currentTimeZone,
        );
        if (success) {
          log("Token successfully registered with backend.");
        } else {
          log("Failed to register token with backend.");
          // Implement retry logic?
        }
      } else {
        log("Failed to get FCM token.");
      }
    } catch (e) {
      log("Error getting/registering FCM token: $e");
    }
  }

  // Call this when the user logs in successfully
  Future<void> registerTokenOnLogin() async {
    log("User logged in, attempting to register token.");
    await _getTokenAndRegister();
  }

  // Call this when the user logs out
  Future<void> unregisterTokenOnLogout(String userId) async {
    log("User logging out, attempting to unregister token.");
    if (_currentToken != null) {
      try {
        await _apiClient.unregisterToken(token: _currentToken!, userId: userId);
        log("Token unregistered from backend.");
      } catch (e) {
        log("Error unregistering token from backend: $e");
      } finally {
        _currentToken = null; // Clear local token on logout
      }
    } else {
      log("No current token found to unregister.");
    }
  }

  void _handleTokenRefresh(String newToken) {
    log('FCM Token Refreshed: $newToken');
    _currentToken = newToken;
    // Re-register the new token with the backend if user is logged in
    final userId = _authRepository.getCurrentUserId();
    if (userId != null && _currentToken != null) {
      log('Attempting to register refreshed token...');
      // Get timezone again (it shouldn't change often, but safer)
      FlutterTimezone.getLocalTimezone()
          .then((timezone) {
            _apiClient.registerToken(
              token: _currentToken!,
              userId: userId,
              timezone: timezone,
            );
          })
          .catchError((e) {
            log("Error getting timezone during token refresh: $e");
            // Register without timezone maybe? Or handle error.
          });
    }
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

  // --- Tap Handling ---
  Future<void> onSelectNotification(String? payload) async {
    debugPrint('Notification tapped with payload: $payload');
    if (payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(payload);
        final String? type = data['type'];
        final String? goalId = data['goalId'];
        log('Handling tap on local notification. Type: $type, GoalId: $goalId');

        // TODO: Implement navigation or action based on notification type
        if (type == 'new_goal' ||
            type == 'deadline_reminder' ||
            type == 'goal_completed') {
          // Example: Navigate to goal details screen if goalId exists
          if (goalId != null) {
            // Use your navigation service or context to navigate
            // navigatorKey.currentState?.pushNamed('/goalDetails', arguments: goalId);
            log("Navigate to goal: $goalId");
          }
        } else if (type == 'welcome' ||
            type == 'morning_greeting' ||
            type == 'evening_summary') {
          // Example: Navigate to home screen or dashboard
          // navigatorKey.currentState?.pushNamed('/home');
          log("Navigate to home/dashboard");
        }
      } catch (e) {
        log("Error decoding or handling notification payload: $e");
      }
    }
  }

  Future<void> showDataNotification(Map<String, dynamic> data) async {
    // Check if the message has a notification payload.
    // If it does, the OS may already be displaying it.
    // if (message.notification != null) {
    //   log(
    //     "Message contains a notification payload; skipping local notification.",
    //   );
    //   return;
    // }
    if (!_pluginInitialized) await setupNotification(); // Ensure initialized
    if (!_pluginInitialized) {
      log("Notification plugin not initialized. Cannot show notification.");
      return;
    }

    final String? title = data['title'] ?? 'Notification'; // Use data fields
    final String? body = data['body'];
    final String? type = data['type']; // Use type for specific logic if needed
    final String? goalId = data['goalId'];

    log(
      "Attempting to show local notification from data: Title='$title', Body='$body', Type='$type'",
    );

    if (body != null) {
      // Only need body to show something
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            notificationChannelId,
            notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher", // Check icon name
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final int notificationId =
          (type ?? '${goalId ?? ''}${DateTime.now().second}').hashCode;

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(data),
      );
    }
  }

  /// Schedules a local notification at a specific DateTime.
  // Future<void> scheduleNotification({required GoalModel goal}) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         notificationChannelId,
  //         notificationChannelName,
  //         channelDescription: notificationChannelDescription,
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       );
  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //   );

  //   await _flutterLocalNotificationsPlugin.zonedSchedule(
  //     (goal.id).hashCode,
  //     goal.title,
  //     'Your goal "${goal.title}" is due now!',
  //     tz.TZDateTime.from(goal.deadline ?? DateTime.now(), tz.local),
  //     notificationDetails,
  //     matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  /// Notification handler for when the app is in the background or terminated.
  Future<void> _setupNotificationHandler() async {
    //forground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('Received a message while in the foreground: ${message.toMap()}');
      // IMPORTANT: Decide how to handle foreground messages.
      // Option 1: Always show using your custom local notification (using data).
      await showDataNotification(message.data);
    });
    //background message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification caused app to open from background:');
      log('Data: ${message.data}');
      // Don't show notification again, just handle the tap action
      onSelectNotification(jsonEncode(message.data)); // Use the common handler
    });

    //terminated message handler
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        log('Notification caused app to open from terminated state:');
        log('Data: ${message.data}');
        // Don't show notification again, just handle the tap action
        onSelectNotification(
          jsonEncode(message.data),
        ); // Use the common handler
      }
    });
  }
}
