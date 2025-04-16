import 'package:ai_tracking_app/core/utils/responsive_design.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.instance<GoalBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: getDesignSize(context),
        child: MaterialApp(
          title: 'Goal Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: GoalListScreen(),
        ),
      ),
    );
  }
}
