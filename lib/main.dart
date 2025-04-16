import 'package:ai_tracking_app/core/di/dependency_injection.dart';
import 'package:ai_tracking_app/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// initializing dotenv
  await dotenv.load(fileName: '.env');

  /// initializing firebase
  await FirebaseService.init();

  /// Initialize Firebase Messaging
  await NotificationService.instance.initialize();

  // Init GetIt
  setupLocator();

  runApp(AiTrackingApp());
}
