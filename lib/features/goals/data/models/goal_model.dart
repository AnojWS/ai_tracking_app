import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? deadline;

  GoalModel({
    required this.id,
    required this.title,
    this.isDone = false,
    this.deadline,
  });

  /// Convert Firestore data to GoalModel
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      deadline:
          data['deadline'] != null
              ? (data['deadline'] as Timestamp)
                  .toDate() // Convert Timestamp to DateTime
              : null,
    );
  }

  /// Convert GoalModel to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isDone': isDone,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
    };
  }
}
