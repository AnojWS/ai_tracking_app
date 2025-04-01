part of 'goal_bloc.dart';

@immutable
class GoalState extends Equatable {
  final DateTime? addDeadline;
  final DateTime? editDeadline;

  const GoalState({required this.addDeadline, required this.editDeadline});

  GoalState clone({DateTime? addDeadline, DateTime? editDeadline}) {
    return GoalState(
      addDeadline: addDeadline ?? this.addDeadline,
      editDeadline: editDeadline ?? this.editDeadline,
    );
  }

  static GoalState get initialState =>
      const GoalState(addDeadline: null, editDeadline: null);

  @override
  List<Object?> get props => [addDeadline, editDeadline];
}
