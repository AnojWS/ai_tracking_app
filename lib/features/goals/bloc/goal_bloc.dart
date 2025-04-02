import 'dart:async';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:ai_tracking_app/features/goals/data/repositories/goal_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository goalRepository;
  StreamSubscription<List<GoalModel>>? _goalSubscription;
  GoalBloc({required this.goalRepository}) : super(GoalState.initialState) {
    on<SubscribeGoals>(_subscribeGoals);
    on<GoalsUpdated>(_onGoalsUpdated);
    on<SetAddDedLine>(_setAddDedLine);
    on<SetEditDedLine>(_setEditDedLine);
    on<AddGoal>(_addGoal);
    on<UpdateGoal>(_updateGoal);
    on<UpdateGoalStatus>(_updateGoalStatus);
    on<DeleteGoal>(_deleteGoal);
    on<ClearAllGoals>(_clearAllGoals);

    _goalSubscription = goalRepository.getGoals().listen((goals) {
      add(GoalsUpdated(goals));
    });
  }

  _setAddDedLine(SetAddDedLine event, Emitter<GoalState> emit) {
    emit(state.clone(addDeadline: event.deadline));
  }

  _setEditDedLine(SetEditDedLine event, Emitter<GoalState> emit) {
    emit(state.clone(editDeadline: event.deadline));
  }

  void _addGoal(AddGoal event, Emitter<GoalState> emit) async {
    await goalRepository.saveGoal(event.goal);
    emit(state.clone(addDeadline: null));
  }

  void _updateGoalStatus(
    UpdateGoalStatus event,
    Emitter<GoalState> emit,
  ) async {
    await goalRepository.updateGoalStatus(event.goalId, event.isDone);
  }

  void _updateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    await goalRepository.updateGoal(
      event.goal.id,
      event.goal.title,
      event.goal.deadline,
    );
  }

  void _deleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    await goalRepository.deleteGoal(event.goalId);
  }

  void _clearAllGoals(ClearAllGoals event, Emitter<GoalState> emit) async {
    await goalRepository.clearAllGoals();
  }

  _subscribeGoals(SubscribeGoals event, Emitter<GoalState> emit) {
    // Could be used to trigger a refresh manually if needed.
  }

  _onGoalsUpdated(GoalsUpdated event, Emitter<GoalState> emit) {
    emit(state.clone(goals: event.goals));
  }

  @override
  Future<void> close() {
    _goalSubscription?.cancel();
    return super.close();
  }
}
