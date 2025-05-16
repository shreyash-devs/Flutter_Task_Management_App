import '../repositories/task_repository_interface.dart';
import '../../data/models/task_model.dart';

class AddTaskUseCase {
  final TaskRepositoryInterface repository;
  AddTaskUseCase(this.repository);

  Future<void> call(Task task) => repository.addTask(task);
}
