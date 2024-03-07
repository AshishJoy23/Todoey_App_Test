import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  TaskModel(
      {
      required this.title,
      required this.subtitle,
      required this.taskTime,
      required this.taskDate,
      required this.isCompleted});

  /// TITLE
  @HiveField(0)
  String title;

  /// SUBTITLE
  @HiveField(1)
  String subtitle;

  /// CREATED AT TIME
  @HiveField(2)
  String taskTime;

  /// CREATED AT DATE
  @HiveField(3)
  String taskDate;

  /// IS COMPLETED
  @HiveField(4)
  bool isCompleted;

  /// create new TaskModel 
  factory TaskModel.create({
    required String? title,
    required String? subtitle,
    required String? taskTime,
    required String? taskDate,
  }) =>
      TaskModel(
        title: title ?? "",
        subtitle: subtitle ?? "",
        taskTime: taskTime ?? DateTime.now().toString(),
        isCompleted: false,
        taskDate: taskDate ?? DateTime.now().toString(),
      );
}