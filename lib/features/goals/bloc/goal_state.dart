part of 'goal_bloc.dart';

@immutable
class GoalState extends Equatable {
  final List<GoalModel> goals;
  final DateTime? addDeadline;
  final DateTime? editDeadline;

  const GoalState({
    required this.goals,
    required this.addDeadline,
    required this.editDeadline,
  });

  GoalState clone({
    List<GoalModel>? goals,
    DateTime? addDeadline,
    DateTime? editDeadline,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      addDeadline: addDeadline ?? this.addDeadline,
      editDeadline: editDeadline ?? this.editDeadline,
    );
  }

  static GoalState get initialState =>
      const GoalState(goals: [], addDeadline: null, editDeadline: null);

  @override
  List<Object?> get props => [goals, addDeadline, editDeadline];
}
