import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/firebase_service.dart';
import '../../data/models/goal_model.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

  void _showAddGoalDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Goal'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter your goal'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final newGoal = GoalModel(
                    id: DateTime.now().toString(),
                    title: controller.text,
                  );
                  FirebaseService.saveGoal(newGoal);
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

  void _showEditGoalDialog(BuildContext context, GoalModel goal) {
    final TextEditingController controller = TextEditingController(
      text: goal.title,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Goal'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Update your goal'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  FirebaseService.updateGoalTitle(goal.id, controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete All Goals'),
          content: Text('Are you sure you want to delete all goals?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseService.clearAllGoals();
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
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
                onTap: () => _showEditGoalDialog(context, goals[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: goals[index].isDone,
                      onChanged: (newValue) {
                        FirebaseService.updateGoalStatus(
                          goals[index].id,
                          newValue!,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseService.deleteGoal(goals[index].id);
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
        onPressed: () => _showAddGoalDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
