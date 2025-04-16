import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:ai_tracking_app/features/goals/presentation/widgets/add_goal_dialog.dart';
import 'package:ai_tracking_app/features/goals/presentation/widgets/delete_all_dialog.dart';
import 'package:ai_tracking_app/features/goals/presentation/widgets/edit_goal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogManager {
  static Future<void> showAddGoalDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AddGoalDialog(),
    );
  }

  static Future<void> showEditGoalDialog(BuildContext context, GoalModel goal) {
    return showDialog(
      context: context,
      builder: (dialogContext) => EditGoalDialog(goal: goal),
    );
  }

  static Future<void> showDeleteAllDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: BlocProvider.of<GoalBloc>(context),
            child: DeleteAllDialog(),
          ),
    );
  }

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(buttonText, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
