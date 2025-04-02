import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/repositories/goal_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register GoalRepository as a lazy singleton.
  getIt.registerLazySingleton<GoalRepository>(() => GoalRepository());

  // Register GoalBloc as a factory. A new instance is created whenever it is requested.
  getIt.registerFactory<GoalBloc>(
    () => GoalBloc(goalRepository: getIt<GoalRepository>()),
  );
}
