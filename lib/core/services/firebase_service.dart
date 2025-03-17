import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/goals/data/models/goal_model.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCt82qoGD_G355QnsukHQ1bo_TPO4ASpZk",
        appId: "1:734684488371:android:1b68625be8aee31a0446c6",
        messagingSenderId: "734684488371",
        projectId: "ai-tracking-app",
      ),
    );
  }

  static final _firestore = FirebaseFirestore.instance;

  static Future<void> saveGoal(GoalModel goal) async {
    await _firestore.collection('goals').doc(goal.id).set({
      'title': goal.title,
      'isDone': goal.isDone,
    });
  }
}
