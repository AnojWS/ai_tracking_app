import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:ai_tracking_app/features/goals/presentation/widgets/add_goal_dialog.dart';
import 'package:ai_tracking_app/features/goals/presentation/widgets/delete_all_dialog.dart';
import 'package:ai_tracking_app/features/goals/presentation/widgets/edit_goal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogManager {
  /// Shows the dialog to add a new goal.
  /// It provides the existing GoalBloc instance to the AddGoalDialog.
  static Future<void> showAddGoalDialog(BuildContext context) {
    // Retrieve the GoalBloc from the context where the dialog is launched from
    // (e.g., GoalListScreen's context).
    final goalBloc =
        context.read<GoalBloc>(); // Use context.read for simplicity

    return showDialog(
      context: context,
      // Provide the retrieved GoalBloc instance to the dialog's widget tree.
      builder:
          (dialogContext) => BlocProvider.value(
            value: goalBloc, // Pass the existing Bloc instance
            child: AddGoalDialog(), // The dialog widget
          ),
    );
  }

  /// Shows the dialog to edit an existing goal.
  /// It provides the existing GoalBloc instance to the EditGoalDialog.
  static Future<void> showEditGoalDialog(BuildContext context, GoalModel goal) {
    // Retrieve the GoalBloc from the context where the dialog is launched from.
    final goalBloc = context.read<GoalBloc>();

    return showDialog(
      context: context,
      // Provide the retrieved GoalBloc instance to the dialog's widget tree.
      builder:
          (dialogContext) => BlocProvider.value(
            value: goalBloc, // Pass the existing Bloc instance
            child: EditGoalDialog(goal: goal), // The dialog widget
          ),
    );
  }

  /// Shows the dialog to confirm deleting all goals.
  /// It provides the existing GoalBloc instance to the DeleteAllDialog.
  /// (This implementation was already correct)
  static Future<void> showDeleteAllDialog(BuildContext context) {
    // Retrieve the GoalBloc from the context where the dialog is launched from.
    final goalBloc = context.read<GoalBloc>();

    return showDialog(
      context: context,
      // Provide the retrieved GoalBloc instance to the dialog's widget tree.
      builder:
          (dialogContext) => BlocProvider.value(
            value: goalBloc, // Pass the existing Bloc instance
            child: DeleteAllDialog(), // The dialog widget
          ),
    );
  }

  /// Shows a generic confirmation dialog.
  /// This does not require GoalBloc directly.
  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (alertDialogContext) {
        // Use a different name to avoid confusion
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator.pop(alertDialogContext), // Use dialog's context
              child: const Text('Cancel'),
            ),
            TextButton(
              // The onPressed callback is executed in the context where
              // showConfirmationDialog was called, which should have GoalBloc if needed.
              onPressed: () {
                onPressed(); // Execute the provided callback
                Navigator.pop(alertDialogContext); // Close dialog after action
              },
              child: Text(buttonText, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
