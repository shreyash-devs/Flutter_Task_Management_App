import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/usecases/add_task_usecase.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());
final addTaskUseCaseProvider = Provider(
  (ref) => AddTaskUseCase(ref.read(taskRepositoryProvider)),
);
