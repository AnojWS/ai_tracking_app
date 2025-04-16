import 'package:ai_tracking_app/core/utils/dialog_manager.dart';
import 'package:ai_tracking_app/features/auth/bloc/auth_bloc.dart';
import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user info (optional, for display)
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? user?.email ?? 'My Goals'),
        actions: [
          // Delete All Button (Keep existing functionality)
          IconButton(
            tooltip: 'Delete All Goals',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed:
                () => DialogManager.showDeleteAllDialog(
                  context,
                ), // Ensure DialogManager uses GoalBloc correctly
          ),
          // Sign Out Button
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add the sign out event to AuthBloc
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<GoalBloc, GoalState>(
        // listenWhen: (previous, current) => previous.status != current.status,
        buildWhen: (previous, current) => previous.goals != current.goals,
        listener: (context, state) {
          // if (state.status == GoalStatus.error) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text(state.error ?? 'An error occurred')),
          //   );
          // }
        },
        builder: (context, state) {
          // Optional: Add loading state display
          // if (state.status == GoalStatus.loading) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          if (state.goals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Goals Yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Tap the + button to add your first goal.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
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
                    color: goal.isDone ? Colors.grey : null,
                  ),
                ),
                subtitle:
                    goal.deadline !=
                            null // Show deadline if exists
                        ? Text(
                          'Deadline: ${MaterialLocalizations.of(context).formatShortDate(goal.deadline!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                        : null,
                onTap: () => DialogManager.showEditGoalDialog(context, goal),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: goal.isDone,
                      activeColor:
                          Theme.of(context).primaryColor, // Use theme color
                      onChanged: (newValue) {
                        if (newValue != null) {
                          context.read<GoalBloc>().add(
                            UpdateGoalStatus(goalId: goal.id, isDone: newValue),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                      tooltip: 'Delete Goal',
                      onPressed: () {
                        // Optional: Show confirmation dialog before deleting
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
        tooltip: 'Add Goal',
        onPressed: () => DialogManager.showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
