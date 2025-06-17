// lib/features/todo/providers/todo_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/todo/models/todo_model.dart';
import 'package:madoi/features/todo/repositories/todo_repository.dart';

// Repository
final todoRepositoryProvider = Provider((ref) => TodoRepository());

// Controller
final todoControllerProvider = Provider((ref) {
  return TodoController(todoRepository: ref.watch(todoRepositoryProvider));
});

// ToDo一覧を取得するStreamProvider.family
final todosProvider = StreamProvider.family<List<TodoModel>, String>((
  ref,
  vehicleId,
) {
  return ref.watch(todoRepositoryProvider).getTodosStream(vehicleId);
});

class TodoController {
  final TodoRepository _todoRepository;
  TodoController({required TodoRepository todoRepository})
    : _todoRepository = todoRepository;

  Future<void> addTodo({
    required String content,
    required String vehicleId,
    required String workspaceId,
  }) async {
    await _todoRepository.addTodo(
      content: content,
      vehicleId: vehicleId,
      workspaceId: workspaceId,
    );
  }

  Future<void> toggleTodoStatus({
    required String todoId,
    required bool currentStatus,
  }) async {
    await _todoRepository.toggleTodoStatus(
      todoId: todoId,
      currentStatus: currentStatus,
    );
  }
}
