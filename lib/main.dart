import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Load env file
  await dotenv.load(fileName: ".env");

  /// initializing firebase
  await FirebaseService.init();

  runApp(AiTrackingApp());
}
