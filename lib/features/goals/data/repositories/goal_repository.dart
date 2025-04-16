import 'dart:developer';

import 'package:ai_tracking_app/core/network/api_client.dart';
import 'package:ai_tracking_app/features/auth/data/repositories/auth_repository.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository;
  final ApiClient _apiClient; // Inject ApiClient

  GoalRepository({
    required AuthRepository authRepository,
    required ApiClient apiClient, // Add constructor parameter
  }) : _authRepository = authRepository,
       _apiClient = apiClient;

  // Helper to get user ID (could also be passed directly to methods)
  String _getUserId() {
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      throw Exception("User not logged in.");
    }
    return userId;
  }

  // Helper to get the current user's goals collection reference
  CollectionReference _getGoalsCollection() {
    return _firestore.collection('users').doc(_getUserId()).collection('goals');
  }

  Stream<List<GoalModel>> getGoals() {
    try {
      return _getGoalsCollection()
          .orderBy('deadline') // Optional: order by deadline or another field
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => GoalModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      log("Error getting goals stream: $e");
      // Return an empty stream or stream with error
      return Stream.value([]);
    }
  }

  Future<void> saveGoal(GoalModel goal) async {
    final userId = _getUserId();
    try {
      final newDocRef = _getGoalsCollection().doc();
      final goalWithId = GoalModel(
        id: newDocRef.id,
        title: goal.title,
        isDone: goal.isDone,
        deadline: goal.deadline,
        // Add reminderSent: false explicitly if needed by backend logic on create
        // reminderSent: false,
      );
      await newDocRef.set(goalWithId.toFirestore());

      // ---> Notify backend about the new goal <---
      await _apiClient.notifyNewGoal(userId: userId, goal: goalWithId);
      await _apiClient.trackInteraction(
        userId: userId,
        eventType: 'goal_add',
        details: {'goalId': goalWithId.id},
      );
    } catch (e) {
      log("Error saving goal: $e");
      rethrow; // Rethrow to be handled by the Bloc/UI
    }
  }

  // Update goal status for the current user
  Future<void> updateGoalStatus(String goalId, bool isDone) async {
    final userId = _getUserId();
    try {
      await _getGoalsCollection().doc(goalId).update({'isDone': isDone});
      // ---> Notify backend if goal is completed <---
      if (isDone) {
        // Fetch the goal title to send to backend (or backend retrieves it)
        final goalDoc = await _getGoalsCollection().doc(goalId).get();
        if (goalDoc.exists) {
          final completedGoal = GoalModel.fromFirestore(goalDoc);
          await _apiClient.notifyGoalCompleted(
            userId: userId,
            goal: completedGoal,
          );
          await _apiClient.trackInteraction(
            userId: userId,
            eventType: 'goal_complete',
            details: {'goalId': goalId},
          );
        }
      } else {
        // Track goal un-completion
        await _apiClient.trackInteraction(
          userId: userId,
          eventType: 'goal_uncomplete',
          details: {'goalId': goalId},
        );
      }
    } catch (e) {
      log("Error updating goal status: $e");
      rethrow;
    }
  }

  // Update goal details for the current user
  Future<void> updateGoal(GoalModel goal) async {
    final userId = _getUserId();
    try {
      await _getGoalsCollection().doc(goal.id).update({
        'title': goal.title,
        'deadline':
            goal.deadline != null ? Timestamp.fromDate(goal.deadline!) : null,
        'isDone': goal.isDone,
        // ---> IMPORTANT: Reset reminder flag if deadline changes <---
        'reminderSent': false,
      });

      await _apiClient.trackInteraction(
        userId: userId,
        eventType: 'goal_update',
        details: {'goalId': goal.id},
      );
      // Optional: Notify backend about update if specific logic needed
      // await _apiClient.notifyGoalUpdated(userId: userId, goal: goal);
    } catch (e) {
      log("Error updating goal: $e");
      rethrow;
    }
  }

  // Delete a goal for the current user
  Future<void> deleteGoal(String goalId) async {
    final userId = _getUserId();
    try {
      await _getGoalsCollection().doc(goalId).delete();
      await _apiClient.trackInteraction(
        userId: userId,
        eventType: 'goal_delete',
        details: {'goalId': goalId},
      );
      // Optional: Notify backend if needed (e.g., to clean up related data)
    } catch (e) {
      log("Error deleting goal: $e");
      rethrow;
    }
  }

  // Clear all goals for the current user
  Future<void> clearAllGoals() async {
    final userId = _getUserId();
    try {
      final goalsCollection = _getGoalsCollection();
      final goalsSnapshot = await goalsCollection.get();
      // Use batch write for efficiency
      final batch = _firestore.batch();
      for (var doc in goalsSnapshot.docs) {
        batch.delete(doc.reference);
        // Cancel notifications for each goal being deleted
        // await _notificationService.cancelNotification(doc.id);
      }
      await batch.commit();

      await _apiClient.trackInteraction(
        userId: userId,
        eventType: 'goals_clear_all',
      );
    } catch (e) {
      log("Error clearing all goals: $e");
      rethrow;
    }
  }
}
