import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoey_aventus_test/model/task_model.dart';

class HiveDbServices {
  static const boxName = "tasksBox";
  final Box<TaskModel> box = Hive.box<TaskModel>(boxName);

  /// Add new Task
  Future<void> addTask({required TaskModel task}) async {
    await box.add(task);
  }


  /// Update task
  Future<void> updateTask({required TaskModel task}) async {
    await task.save();
  }

  /// Delete task
  Future<void> deleteTask({required TaskModel task}) async {
    await task.delete();
  }

  ValueListenable<Box<TaskModel>> listenToTask() {
    return box.listenable();
  }
}