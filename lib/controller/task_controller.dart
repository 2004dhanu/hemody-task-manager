import 'package:herodydemo/e/e.dart';
import 'package:herodydemo/model/task_model.dart';

class TaskController {

  final FirebaseService _service = FirebaseService();

  Stream<List<Task>> fetchTasks() {
    return _service.getTasks();
  }

  Future<void> addTask(
    String title,
    String description,
    DateTime? dueDate, {
    int priority = 1,
    String category = 'Personal',
  }) {
    return _service.addTask(
      title,
      description,
      dueDate,
      priority: priority,
      category: category,
    );
  }

  Future<void> toggleTask(Task task) {
    task.completed = !task.completed;
    return _service.updateTask(task);
  }

  Future<void> deleteTask(String id) {
    return _service.deleteTask(id);
  }

  Future<void> editTask(
    String id,
    String title,
    String description,
    DateTime? dueDate,
  ) {
    return _service.editTask(id, title, description, dueDate);
  }
}