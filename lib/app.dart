import 'package:ai_tracking_app/features/goals/presentation/screens/goal_list_screen.dart';
import 'package:flutter/material.dart';

class AiTrackingApp extends StatelessWidget {
  const AiTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GoalListScreen(), // You'll create this next
    );
  }
}
