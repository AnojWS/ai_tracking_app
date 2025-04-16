import 'package:ai_tracking_app/core/network/api_client.dart';
import 'package:ai_tracking_app/core/services/notification_service.dart';
import 'package:ai_tracking_app/features/auth/bloc/auth_bloc.dart';
import 'package:ai_tracking_app/features/auth/data/repositories/auth_repository.dart';
import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/repositories/goal_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // --- External Services ---
  // Register Firebase Auth and Google Sign-In instances
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // --- Network Client ---
  // Register ApiClient (using Dio internally)
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // --- Repositories ---
  // Register AuthRepository (depends on FirebaseAuth and GoogleSignIn)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  /// Register GoalRepository (now depends on AuthRepository to get user ID)
  getIt.registerLazySingleton<GoalRepository>(
    () => GoalRepository(
      authRepository: getIt<AuthRepository>(),
      apiClient: getIt<ApiClient>(),
    ),
  );

  /// --- Blocs ---
  // AuthBloc depends on AuthRepository and needs ApiClient for unregistering token on signout
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      apiClient: getIt<ApiClient>(), // Inject ApiClient
      notificationService:
          getIt<NotificationService>(), // Inject NotificationService
    ),
  );

  /// Register GoalBloc (depends on GoalRepository)
  getIt.registerFactory<GoalBloc>(
    () => GoalBloc(goalRepository: getIt<GoalRepository>()),
  );

  // --- Services ---
  // NotificationService might need AuthRepository to get userId if registration happens here
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService.instance, // Access via instance is okay too
    // Or if you prefer injecting dependencies:
    // () => NotificationService(authRepository: getIt<AuthRepository>(), apiClient: getIt<ApiClient>()),
  );
}
