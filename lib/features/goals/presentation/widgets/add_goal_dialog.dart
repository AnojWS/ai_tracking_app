import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:ai_tracking_app/features/widgets/common_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final TextEditingController _tittleController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

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
          (previous, current) => previous.addDeadline != current.addDeadline,
      builder: (context, state) {
        return AlertDialog(
          title: Text('Add a Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tittleController,
                decoration: InputDecoration(hintText: 'Enter your goal'),
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
                      SetAddDedLine(deadline: deadline),
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_tittleController.text.isNotEmpty) {
                  final newGoal = GoalModel(
                    id: DateTime.now().toString(),
                    title: _tittleController.text,
                    deadline: state.addDeadline,
                  );
                  context.read<GoalBloc>().add(AddGoal(newGoal));
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
