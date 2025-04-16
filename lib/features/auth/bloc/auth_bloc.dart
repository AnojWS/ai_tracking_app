import 'dart:async';
import 'dart:developer';

import 'package:ai_tracking_app/core/constants/app_enums.dart';
import 'package:ai_tracking_app/core/network/api_client.dart';
import 'package:ai_tracking_app/core/services/notification_service.dart';
import 'package:ai_tracking_app/features/auth/data/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final NotificationService _notificationService; // Add NotificationService
  final ApiClient _apiClient; // Add ApiClient for direct calls if needed
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required NotificationService notificationService, // Inject
    required ApiClient apiClient, // Inject
  }) : _authRepository = authRepository,
       _notificationService = notificationService,
       _apiClient = apiClient,
       super(const AuthState.unknown()) {
    // Start unknown

    // Register event handlers
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthSendWelcomeNotification>(_onAuthSendWelcomeNotification);
    on<CheckbackendHealth>((event, emit) async {
      try {
        final isHealthy = await _apiClient.checkHealth();
        if (isHealthy) {
          log("Backend is healthy");
        } else {
          log("Backend is unhealthy");
        }
      } catch (e) {
        log("Error checking backend health: $e");
      }
    });

    // Subscribe to the user stream from the repository
    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthUserChanged(user)), // Add event when user changes
    );
  }

  // Handler for when the user state changes (login/logout)
  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      // User is logged in
      emit(AuthState.authenticated(event.user!));
      // ---> Register FCM token when user logs in <---
      _notificationService.registerTokenOnLogin();

      // ---> Trigger Welcome Notification (if first time) <---
      // Logic to check if it's the actual *first* login needs implementation
      // Example: Check a flag in user profile or local storage
      // bool isFirstLogin = await checkIsFirstLogin(event.user!.uid);
      // if (isFirstLogin) {
      //    add(AuthSendWelcomeNotification(userId: event.user!.uid, displayName: event.user!.displayName));
      // }

      // ---> Track Login Interaction <---
      _apiClient.trackInteraction(
        userId: event.user!.uid,
        eventType: 'auth_login',
      );
    } else {
      // User is logged out
      emit(const AuthState.unauthenticated());
      // Note: Unregistering token happens in _onAuthSignOutRequested *before* state changes
    }
  }

  // Handler for sign out requests
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final userId = state.user?.uid; // Get user ID *before* signing out

    try {
      // ---> Unregister FCM token BEFORE signing out <---
      if (userId != null) {
        await _notificationService.unregisterTokenOnLogout(userId);
        await _apiClient.trackInteraction(
          userId: userId,
          eventType: 'auth_logout',
        );
      }
      await _authRepository.signOut();
      // State will change via _onAuthUserChanged listener
    } catch (e) {
      log("Error during sign out or token unregistration: $e");
      // Handle error (e.g., show message to user)
    }
  }

  // Handler to explicitly send welcome notification
  Future<void> _onAuthSendWelcomeNotification(
    AuthSendWelcomeNotification event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _apiClient.notifyWelcome(
        userId: event.userId,
        displayName: event.displayName,
      );
      // Optional: Mark first login complete after sending
      // await markFirstLoginComplete(event.userId);
    } catch (e) {
      log("Error sending welcome notification via event: $e");
    }
  }

  // Cancel the subscription when the Bloc is closed
  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
