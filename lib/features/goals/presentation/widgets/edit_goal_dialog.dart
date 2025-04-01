import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:ai_tracking_app/features/widgets/common_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditGoalDialog extends StatefulWidget {
  final GoalModel goal;
  const EditGoalDialog({super.key, required this.goal});

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late final TextEditingController _tittelController;
  late TextEditingController _deadlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tittelController = TextEditingController(text: widget.goal.title);
    _deadlineController =
        widget.goal.deadline != null
            ? TextEditingController(
              text: widget.goal.deadline.toString().substring(0, 16),
            )
            : TextEditingController(text: 'Select deadline');
  }

  Future<DateTime?> _pickDeadline(BuildContext context) async {
    final TimeOfDay? pickedTime;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      if (context.mounted) {
        pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          return DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      buildWhen:
          (previous, current) => previous.editDeadline != current.editDeadline,
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Edit Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tittelController,
                decoration: const InputDecoration(hintText: 'Update your goal'),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () async {
                  final deadline = await _pickDeadline(context);
                  if (deadline != null) {
                    _deadlineController.text = state.addDeadline!
                        .toString()
                        .substring(0, 16);
                  }
                  if (context.mounted) {
                    context.read<GoalBloc>().add(
                      SetEditDedLine(deadline: deadline),
                    );
                  }
                },
                child: AbsorbPointer(
                  child: CommonTextFormFiled(
                    controller: _deadlineController,
                    label: 'Deadline',
                    hintText: 'Select deadline',
                    suffixIcon: const Icon(Icons.calendar_today),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_tittelController.text.isNotEmpty) {
                  context.read<GoalBloc>().add(
                    UpdateGoal(
                      GoalModel(
                        id: widget.goal.id,
                        title: _tittelController.text,
                        isDone: widget.goal.isDone,
                        deadline: state.editDeadline ?? widget.goal.deadline,
                      ),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
