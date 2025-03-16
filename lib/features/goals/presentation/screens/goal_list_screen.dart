// lib/features/goals/presentation/screens/goal_list_screen.dart
import 'package:flutter/material.dart';

import '../../data/models/goal_model.dart';

class GoalListScreen extends StatelessWidget {
  GoalListScreen({super.key});

  final List<GoalModel> dummyGoals = [
    GoalModel(id: '1', title: 'Code for 5 mins', isDone: false),
    GoalModel(id: '2', title: 'Drink water', isDone: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Goals')),
      body: ListView.builder(
        itemCount: dummyGoals.length,
        itemBuilder:
            (context, index) => ListTile(
              title: Text(dummyGoals[index].title),
              trailing: Checkbox(
                value: dummyGoals[index].isDone,
                onChanged: null, // Static for now
              ),
            ),
      ),
    );
  }
}
