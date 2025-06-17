// lib/features/todo/widgets/todo_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:madoi/features/todo/providers/todo_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class TodoTabView extends ConsumerStatefulWidget {
  final String vehicleId;
  const TodoTabView({super.key, required this.vehicleId});

  @override
  ConsumerState<TodoTabView> createState() => _TodoTabViewState();
}

class _TodoTabViewState extends ConsumerState<TodoTabView> {
  final _todoContentController = TextEditingController();

  void _addTodo() {
    final content = _todoContentController.text.trim();
    if (content.isEmpty) return;

    final workspaceId = ref.read(activeWorkspaceProvider).value?.id;
    if (workspaceId == null) return;

    ref
        .read(todoControllerProvider)
        .addTodo(
          content: content,
          vehicleId: widget.vehicleId,
          workspaceId: workspaceId,
        );
    _todoContentController.clear();
    FocusScope.of(context).unfocus(); // キーボードを閉じる
  }

  @override
  void dispose() {
    _todoContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosAsyncValue = ref.watch(todosProvider(widget.vehicleId));

    final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;

    return Scaffold(
      // 1. ToDoリストをbodyに配置
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
              // 未完了タスクのリスト
              ...incompleteTodos.map((todo) {
                return CheckboxListTile(
                  title: Text(todo.content),
                  value: todo.isDone,
                  onChanged: (isDone) {
                    if (activeWorkspaceId != null && isDone != null) {
                      ref
                          .read(todoControllerProvider)
                          .toggleTodoStatus(
                            workspaceId: activeWorkspaceId,
                            vehicleId: widget.vehicleId,
                            todoId: todo.id,
                            isDone: isDone,
                          );
                    }
                  },
                );
              }),
              // 完了済みタスクが1件以上あればExpansionTileを表示
              if (completeTodos.isNotEmpty)
                ExpansionTile(
                  title: Text('完了 (${completeTodos.length})'),
                  children: completeTodos.map((todo) {
                    return CheckboxListTile(
                      title: Text(
                        todo.content,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        '完了: ${DateFormat('yyyy/MM/dd').format((todo.completedAt ?? todo.createdAt).toDate())}',
                      ),
                      value: todo.isDone,
                      onChanged: (isDone) {
                        if (activeWorkspaceId != null && isDone != null) {
                          ref
                              .read(todoControllerProvider)
                              .toggleTodoStatus(
                                workspaceId: activeWorkspaceId,
                                vehicleId: widget.vehicleId,
                                todoId: todo.id,
                                isDone: isDone,
                              );
                        }
                      },
                    );
                  }).toList(),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      // 2. ToDo入力欄を画面下部に配置
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets, // キーボード表示時にUIを押し上げる
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _todoContentController,
            decoration: InputDecoration(
              hintText: '新しいToDoを追加',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addTodo,
              ),
            ),
            onSubmitted: (_) => _addTodo(),
          ),
        ),
      ),
    );
  }
}
