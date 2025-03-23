// lib/features/goals/presentation/screens/goal_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/firebase_service.dart';
import '../../data/models/goal_model.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Goals')),
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
        onPressed: () {
          final newGoal = GoalModel(
            id: DateTime.now().toString(), // Simple unique ID
            title: 'Test Goal ${DateTime.now().second}',
          );
          FirebaseService.saveGoal(newGoal);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
