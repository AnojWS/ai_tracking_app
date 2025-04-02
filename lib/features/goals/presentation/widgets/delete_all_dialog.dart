// lib/features/goals/presentation/widgets/delete_all_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/goal_bloc.dart';

class DeleteAllDialog extends StatelessWidget {
  const DeleteAllDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete All Goals'),
      content: const Text('Are you sure you want to delete all goals?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<GoalBloc>().add(ClearAllGoals());
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
