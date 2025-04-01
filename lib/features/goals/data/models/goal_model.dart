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
}
