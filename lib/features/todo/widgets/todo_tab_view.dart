// lib/features/todo/widgets/todo_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:madoi/features/todo/models/todo_model.dart';
import 'package:madoi/features/todo/providers/todo_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class TodoTabView extends ConsumerWidget {
  final String vehicleId;
  const TodoTabView({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsyncValue = ref.watch(todosProvider(vehicleId));
    final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;

    void toggleStatus(TodoModel todo, bool isDone) {
      if (activeWorkspaceId != null) {
        ref
            .read(todoControllerProvider.notifier)
            .toggleTodoStatus(
              workspaceId: activeWorkspaceId,
              vehicleId: vehicleId,
              todoId: todo.id,
              isDone: isDone,
            );
      }
    }

    Widget buildTodoTile(TodoModel todo) {
      return ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (isDone) => toggleStatus(todo, isDone ?? false),
        ),
        title: Text(
          todo.content,
          style: todo.isDone
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : null,
        ),
        subtitle: todo.isDone && todo.completedAt != null
            ? Text(
                '完了: ${DateFormat('yyyy/MM/dd').format(todo.completedAt!.toDate())}',
              )
            : null,
        onTap: () {
          if (activeWorkspaceId != null) {
            context.push(
              '/workspace/$activeWorkspaceId/vehicle/$vehicleId/todo/${todo.id}',
            );
          }
        },
      );
    }

    return Scaffold(
      body: todosAsyncValue.when(
        data: (todos) {
          final incompleteTodos = todos.where((todo) => !todo.isDone).toList();
          final completeTodos = todos.where((todo) => todo.isDone).toList();
          completeTodos.sort(
            (a, b) => (b.completedAt ?? b.createdAt).compareTo(
              a.completedAt ?? a.createdAt,
            ),
          );

          if (todos.isEmpty) {
            return const Center(child: Text('ToDoはありません'));
          }

          return ListView(
            children: [
              ...incompleteTodos.map(buildTodoTile),
              if (completeTodos.isNotEmpty)
                ExpansionTile(
                  title: Text('完了 (${completeTodos.length})'),
                  children: completeTodos.map(buildTodoTile).toList(),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      // ★ フローティングアクションボタンを追加
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (activeWorkspaceId != null) {
            context.push(
              '/workspace/$activeWorkspaceId/vehicle/$vehicleId/add-todo',
            );
          }
        },
        tooltip: '新しいToDoを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
