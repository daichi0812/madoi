// lib/features/todo/providers/todo_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/todo/models/todo_model.dart';
import 'package:madoi/features/todo/repositories/todo_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

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
  // アクティブなワークスペースのIDを取得
  final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;

  if (activeWorkspaceId == null) {
    return Stream.value([]);
  }

  return ref
      .watch(todoRepositoryProvider)
      .getTodosStream(vehicleId: vehicleId, workspaceId: activeWorkspaceId);
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
    required String workspaceId,
    required String vehicleId,
    required String todoId,
    required bool isDone,
  }) async {
    await _todoRepository.toggleTodoStatus(
      workspaceId: workspaceId,
      vehicleId: vehicleId,
      todoId: todoId,
      isDone: isDone,
    );
  }
}
