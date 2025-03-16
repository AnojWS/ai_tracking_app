class GoalModel {
  final String id;
  final String title;
  final bool isDone;

  GoalModel({
    required this.id,
    required this.title,
    this.isDone = false,
  });
}