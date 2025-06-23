// lib/features/todo/providers/todo_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer';

import 'package:madoi/features/todo/models/todo_model.dart';
import 'package:madoi/features/todo/repositories/todo_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

// Repository
final todoRepositoryProvider = Provider((ref) => TodoRepository());

// 詳細画面用の引数クラスを作成
class TodoDetailProviderArgs extends Equatable {
  final String workspaceId;
  final String vehicleId;
  final String todoId;

  const TodoDetailProviderArgs({
    required this.workspaceId,
    required this.vehicleId,
    required this.todoId,
  });

  @override
  List<Object?> get props => [workspaceId, vehicleId, todoId];
}

// 単一のToDoを取得するためのProvider.familyを追加
final todoDetailProvider =
    StreamProvider.family<TodoModel?, TodoDetailProviderArgs>((ref, args) {
      return ref
          .watch(todoRepositoryProvider)
          .getTodoStream(
            workspaceId: args.workspaceId,
            vehicleId: args.vehicleId,
            todoId: args.todoId,
          );
    });

// Controller
final todoControllerProvider = StateNotifierProvider<TodoController, bool>((
  ref,
) {
  final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;
  return TodoController(
    todoRepository: ref.watch(todoRepositoryProvider),
    workspaceId: activeWorkspaceId,
    ref: ref,
  );
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

class TodoController extends StateNotifier<bool> {
  final TodoRepository _todoRepository;
  final String? _workspaceId;
  final Ref _ref;
  TodoController({
    required TodoRepository todoRepository,
    required String? workspaceId,
    required Ref ref,
  }) : _todoRepository = todoRepository,
       _workspaceId = workspaceId,
       _ref = ref,
       super(false);

  Future<bool> addTodo({
    required BuildContext context,
    required String content,
    required String vehicleId,
    required String workspaceId,
  }) async {
    state = false;
    bool isSuccess = false;
    try {
      await _todoRepository.addTodo(
        content: content,
        vehicleId: vehicleId,
        workspaceId: workspaceId,
      );
      isSuccess = true;
    } catch (e) {
      log('ToDo追加エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: ${e.toString()}')));
      }
    } finally {
      state = false;
    }
    return isSuccess;
  }

  // ToDo更新メソッドを追加
  Future<bool> updateTodo({
    required BuildContext context,
    required String todoId,
    required String content,
    required String vehicleId,
    required String workspaceId,
  }) async {
    state = true;
    bool isSuccess = false;
    try {
      await _todoRepository.updateTodo(
        workspaceId: workspaceId,
        vehicleId: vehicleId,
        todoId: todoId,
        content: content,
      );
      isSuccess = true;
    } catch (e) {
      log('ToDo更新エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: ${e.toString()}')));
      }
    } finally {
      state = false;
    }
    return isSuccess;
  }

  // 並び替えメソッドを追加
  Future<void> reorderTodos({
    required String vehicleId,
    required int oldIndex,
    required int newIndex,
  }) async {
    if (_workspaceId == null) return;

    // 現在のリストを取得
    final todos = _ref.read(todosProvider(vehicleId)).value ?? [];
    final incompleteTodos = todos.where((t) => !t.isDone).toList();

    // D&Dのためのインデックス調整
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // リストを並び替え
    final item = incompleteTodos.removeAt(oldIndex);
    incompleteTodos.insert(newIndex, item);

    await _todoRepository.reorderTodos(
      workspaceId: _workspaceId,
      vehicleId: vehicleId,
      todos: incompleteTodos,
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
    // 完了状態を更新したら未完了リストを再ソートする
    // if (!isDone) {
    //   final todos = _ref.read(todosProvider(vehicleId)).value ?? [];
    //   final incompleteTodos = todos.where((t) => !t.isDone).toList();
    //   await _todoRepository.reorderTodos(
    //     workspaceId: workspaceId,
    //     vehicleId: vehicleId,
    //     todos: incompleteTodos,
    //   );
    // }
  }

  Future<void> deleteTodo({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
  }) async {
    await _todoRepository.deleteTodo(
      workspaceId: workspaceId,
      vehicleId: vehicleId,
      todoId: todoId,
    );
  }
}
