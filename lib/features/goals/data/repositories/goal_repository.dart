import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<GoalModel>> getGoals() {
    return _firestore
        .collection('goals')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> saveGoal(GoalModel goal) async {
    await _firestore.collection('goals').doc(goal.id).set(goal.toFirestore());
  }

  Future<void> updateGoalStatus(String goalId, bool isDone) async {
    await _firestore.collection('goals').doc(goalId).update({'isDone': isDone});
  }

  Future<void> updateGoal(
    String goalId,
    String title,
    DateTime? newDeadline,
  ) async {
    await _firestore.collection('goals').doc(goalId).update({
      'title': title,
      'deadline': newDeadline,
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('goals').doc(goalId).delete();
  }

  Future<void> clearAllGoals() async {
    final goals = await _firestore.collection('goals').get();
    for (var doc in goals.docs) {
      await doc.reference.delete();
    }
  }
}
