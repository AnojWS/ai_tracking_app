import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/goals/data/models/goal_model.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      ),
    );
  }

  static final _firestore = FirebaseFirestore.instance;

  static Future<void> saveGoal(GoalModel goal) async {
    await _firestore.collection('goals').doc(goal.id).set({
      'title': goal.title,
      'isDone': goal.isDone,
      'deadline': goal.deadline?.toIso8601String(),
    });
  }

  static Future<void> updateGoalStatus(String goalId, bool isDone) async {
    await _firestore.collection('goals').doc(goalId).update({'isDone': isDone});
  }

  static Future<void> updateGoal(
    String goalId,
    String title,
    DateTime? newDeadline,
  ) async {
    await _firestore.collection('goals').doc(goalId).update({
      'title': title,
      'deadline': newDeadline,
    });
  }

  static Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('goals').doc(goalId).delete();
  }

  static Future<void> clearAllGoals() async {
    final goals = await _firestore.collection('goals').get();
    for (var doc in goals.docs) {
      await doc.reference.delete();
    }
  }
}
