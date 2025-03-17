import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  /// initializing firebase
  await FirebaseService.init();
  runApp(AiTrackingApp());
}
