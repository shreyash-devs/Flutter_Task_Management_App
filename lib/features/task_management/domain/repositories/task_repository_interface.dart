import '../../data/models/task_model.dart';

abstract class TaskRepositoryInterface {
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Stream<List<Task>> getTasksStream();
  Future<Task?> getTaskById(String taskId);
}
