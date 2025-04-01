part of 'goal_bloc.dart';

@immutable
sealed class GoalEvent {}

class SetAddDedLine extends GoalEvent {
  final DateTime? deadline;

  SetAddDedLine({this.deadline});
}

class SetEditDedLine extends GoalEvent {
  final DateTime? deadline;

  SetEditDedLine({this.deadline});
}

class AddGoal extends GoalEvent {
  final GoalModel goal;
  AddGoal(this.goal);
}

class UpdateGoalStatus extends GoalEvent {
  final String goalId;
  final bool isDone;
  UpdateGoalStatus({required this.goalId, required this.isDone});
}

class UpdateGoal extends GoalEvent {
  final GoalModel goal;
  UpdateGoal(this.goal);
}

class DeleteGoal extends GoalEvent {
  final String goalId;
  DeleteGoal({required this.goalId});
}

class ClearAllGoals extends GoalEvent {}
