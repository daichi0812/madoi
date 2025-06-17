// lib/features/todo/widgets/todo_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/todo/providers/todo_providers.dart';
import 'package:madoi/features/vehicle/providers/vehicle_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class TodoTabView extends ConsumerStatefulWidget {
  final String vehicleId;
  const TodoTabView({super.key, required this.vehicleId});

  @override
  ConsumerState<TodoTabView> createState() => _TodoTabViewState();
}

class _TodoTabViewState extends ConsumerState<TodoTabView> {
  final TextEditingController _todoContentController = TextEditingController();

  void _addTodo() {
    final content = _todoContentController.text.trim();
    final workspaceId = ref.read(activeWorkspaceProvider).value?.id;

    if (content.isNotEmpty && workspaceId != null) {
      ref
          .read(todoControllerProvider)
          .addTodo(
            content: content,
            vehicleId: widget.vehicleId,
            workspaceId: workspaceId,
          );
      _todoContentController.clear();
    }
  }

  @override
  void dispose() {
    _todoContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todosProvider(widget.vehicleId));

    return Column(
      children: [
        Expanded(
          child: todos.when(
            data: (todoList) => ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final todo = todoList[index];
                return CheckboxListTile(
                  title: Text(
                    todo.content,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  value: todo.isCompleted,
                  onChanged: (value) {
                    ref
                        .read(todoControllerProvider)
                        .toggleTodoStatus(
                          todoId: todo.id,
                          currentStatus: todo.isCompleted,
                        );
                  },
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('エラー: $err')),
          ),
        ),
        // ToDo入力欄
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoContentController,
                  decoration: const InputDecoration(
                    labelText: '新しいToDoを追加',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addTodo,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
