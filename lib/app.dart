import 'package:ai_tracking_app/core/constants/app_enums.dart';
import 'package:ai_tracking_app/core/utils/responsive_design.dart';
import 'package:ai_tracking_app/features/auth/bloc/auth_bloc.dart';
import 'package:ai_tracking_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/presentation/screens/goal_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

class AiTrackingApp extends StatelessWidget {
  const AiTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<AuthBloc>(),
      child: ScreenUtilInit(
        designSize: getDesignSize(context),
        child: MaterialApp(
          title: 'Goal Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal, // Changed theme color slightly
            visualDensity: VisualDensity.adaptivePlatformDensity,
            scaffoldBackgroundColor: Colors.grey[100], // Light background
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.teal[600], // App bar color
              foregroundColor: Colors.white, // App bar text/icon color
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.teal[700], // FAB color
              foregroundColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              // Style text fields
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              // Style buttons
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              switch (state.status) {
                case AuthStatus.authenticated:
                  // User is logged in, provide GoalBloc and show GoalListScreen
                  return BlocProvider(
                    create:
                        (context) =>
                            GetIt.instance<GoalBloc>()
                              ..add(SubscribeGoals()), // Start listening
                    child: const GoalListScreen(),
                  );
                case AuthStatus.unauthenticated:
                  // User is logged out, show LoginScreen
                  return const LoginScreen();
                case AuthStatus.unknown:
                  // Show a loading indicator while checking auth status
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
