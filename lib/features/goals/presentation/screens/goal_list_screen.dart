import 'package:ai_tracking_app/core/utils/dialog_manager.dart';
import 'package:ai_tracking_app/features/goals/bloc/goal_bloc.dart';
import 'package:ai_tracking_app/features/goals/data/models/goal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => DialogManager.showDeleteAllDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('goals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final goals =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return GoalModel(
                  id: doc.id,
                  title: data['title'],
                  isDone: data['isDone'],
                  deadline:
                      data['deadline'] != null
                          ? DateTime.parse(data['deadline'])
                          : null,
                );
              }).toList();
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  goals[index].title,
                  style: TextStyle(
                    decoration:
                        goals[index].isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                ),
                onTap:
                    () =>
                        DialogManager.showEditGoalDialog(context, goals[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: goals[index].isDone,
                      onChanged: (newValue) {
                        context.read<GoalBloc>().add(
                          UpdateGoalStatus(
                            goalId: goals[index].id,
                            isDone: newValue!,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        context.read<GoalBloc>().add(
                          DeleteGoal(goalId: goals[index].id),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
