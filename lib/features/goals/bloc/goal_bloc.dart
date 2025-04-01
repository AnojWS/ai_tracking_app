import 'package:ai_tracking_app/core/services/firebase_service.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc() : super(GoalState.initialState) {
    on<SetAddDedLine>(_setAddDedLine);
    on<SetEditDedLine>(_setEditDedLine);
    on<AddGoal>(_addGoal);
    on<UpdateGoal>(_updateGoal);
    on<UpdateGoalStatus>(_updateGoalStatus);
    on<DeleteGoal>(_deleteGoal);
    on<ClearAllGoals>(_clearAllGoals);
  }

  _setAddDedLine(SetAddDedLine event, Emitter<GoalState> emit) {
    emit(state.clone(addDeadline: event.deadline));
  }

  _setEditDedLine(SetEditDedLine event, Emitter<GoalState> emit) {
    emit(state.clone(editDeadline: event.deadline));
  }

  void _addGoal(AddGoal event, Emitter<GoalState> emit) async {
    await FirebaseService.saveGoal(event.goal);
    emit(state.clone(addDeadline: null));
  }

  void _updateGoalStatus(
    UpdateGoalStatus event,
    Emitter<GoalState> emit,
  ) async {
    await FirebaseService.updateGoalStatus(event.goalId, event.isDone);
  }

  void _updateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    await FirebaseService.updateGoal(
      event.goal.id,
      event.goal.title,
      event.goal.deadline,
    );
  }

  void _deleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    await FirebaseService.deleteGoal(event.goalId);
  }

  void _clearAllGoals(ClearAllGoals event, Emitter<GoalState> emit) async {
    await FirebaseService.clearAllGoals();
  }
}
