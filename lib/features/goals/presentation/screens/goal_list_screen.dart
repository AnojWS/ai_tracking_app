import 'package:ai_tracking_app/core/utils/dialog_manager.dart';
import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => DialogManager.showDeleteAllDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<GoalBloc, GoalState>(
        buildWhen: (previous, current) => previous.goals != current.goals,
        builder: (context, state) {
          if (state.goals.isEmpty) {
            return const Center(child: Text('No Goals Added.'));
          }
          return ListView.builder(
            itemCount: state.goals.length,
            itemBuilder: (context, index) {
              final goal = state.goals[index];
              return ListTile(
                title: Text(
                  goal.title,
                  style: TextStyle(
                    decoration:
                        goal.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                ),
                onTap: () => DialogManager.showEditGoalDialog(context, goal),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: goal.isDone,
                      onChanged: (newValue) {
                        context.read<GoalBloc>().add(
                          UpdateGoalStatus(goalId: goal.id, isDone: newValue!),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<GoalBloc>().add(
                          DeleteGoal(goalId: goal.id),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => DialogManager.showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
