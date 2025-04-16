import 'dart:developer';
import 'dart:io'; // For Platform checks

import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  late final Dio _dio;
  final String _baseUrl =
      dotenv.env['BACKEND_BASE_URL'] ??
      'http://192.168.1.4:3000/api'; // Use 10.0.2.2 for Android emulator accessing localhost

  ApiClient() {
    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    );
    _dio = Dio(options);

    // Optional: Add interceptors for logging or adding auth tokens automatically
    // _dio.interceptors.add(
    //   LogInterceptor(
    //     requestBody: true,
    //     responseBody: true,
    //     logPrint: (obj) => log(obj.toString()), // Use dart:developer log
    //   ),
    // );
  }

  // --- Token Management ---
  Future<bool> registerToken({
    required String token,
    required String userId,
    required String timezone, // Timezone ID like 'Asia/Colombo'
  }) async {
    try {
      final response = await _dio.post(
        '/token/register',
        data: {'token': token, 'userId': userId, 'timezone': timezone},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      log(
        'DioError registering token: ${e.response?.statusCode} - ${e.message}',
      );
      return false;
    } catch (e) {
      log('Error registering token: $e');
      return false;
    }
  }

  // need to check the methoed for backend health check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      log("helath check ok ------: ${response.statusMessage}");
      return response.statusCode == 200;
    } on DioException catch (e) {
      log('DioError checking health: ${e.response?.statusCode} - ${e.message}');
      return false;
    } catch (e) {
      log('Error checking health: $e');
      return false;
    }
  }

  Future<bool> unregisterToken({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/token/unregister',
        data: {'token': token, 'userId': userId},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      log(
        'DioError unregistering token: ${e.response?.statusCode} - ${e.message}',
      );
      return false;
    } catch (e) {
      log('Error unregistering token: $e');
      return false;
    }
  }

  // --- Notification Triggers ---
  Future<void> notifyNewGoal({
    required String userId,
    required GoalModel goal,
  }) async {
    try {
      await _dio.post(
        '/notify/new-goal',
        data: {'userId': userId, 'goalId': goal.id, 'goalTitle': goal.title},
      );
    } catch (e) {
      log('Error notifying backend about new goal: $e');
      // Handle silently or show user message?
    }
  }

  Future<void> notifyGoalCompleted({
    required String userId,
    required GoalModel goal,
  }) async {
    try {
      await _dio.post(
        '/notify/goal-completed',
        data: {'userId': userId, 'goalId': goal.id, 'goalTitle': goal.title},
      );
    } catch (e) {
      log('Error notifying backend about goal completion: $e');
    }
  }

  Future<void> notifyWelcome({
    required String userId,
    String? displayName,
  }) async {
    try {
      await _dio.post(
        '/notify/welcome',
        data: {
          'userId': userId,
          if (displayName != null) 'displayName': displayName,
        },
      );
    } catch (e) {
      log('Error triggering welcome notification: $e');
    }
  }

  // --- Interaction Tracking ---
  Future<void> trackInteraction({
    required String userId,
    required String eventType,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _dio.post(
        '/track',
        data: {
          'userId': userId,
          'eventType': eventType,
          'eventTimestamp':
              DateTime.now().toUtc().toIso8601String(), // Send UTC timestamp
          'details': details ?? {},
        },
      );
    } catch (e) {
      log('Error tracking interaction ($eventType): $e');
    }
  }
}
