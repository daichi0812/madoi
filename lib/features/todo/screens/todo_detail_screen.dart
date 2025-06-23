// lib/features/todo/screens/todo_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:madoi/features/todo/providers/todo_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class TodoDetailScreen extends ConsumerWidget {
  final String workspaceId;
  final String vehicleId;
  final String todoId;

  const TodoDetailScreen({
    super.key,
    required this.workspaceId,
    required this.vehicleId,
    required this.todoId,
  });

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('ToDoの削除'),
          content: Text('「$content」を本当に削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                ref
                    .read(todoControllerProvider.notifier)
                    .deleteTodo(
                      workspaceId: workspaceId,
                      vehicleId: vehicleId,
                      todoId: todoId,
                    );
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
                context.pop(); // 詳細画面を閉じる
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsyncValue = ref.watch(
      todoDetailProvider(
        TodoDetailProviderArgs(
          workspaceId: workspaceId,
          vehicleId: vehicleId,
          todoId: todoId,
        ),
      ),
    );
    final members = ref.watch(workspaceMembersProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('タスクの詳細'),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編集',
            onPressed: () {
              context.push(
                '/workspace/$workspaceId/vehicle/$vehicleId/todo/$todoId/edit',
              );
            },
          ),
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
            onPressed: () {
              final todo = todoAsyncValue.value;
              if (todo != null) {
                _showDeleteConfirmationDialog(context, ref, todo.content);
              }
            },
          ),
        ],
      ),
      body: todoAsyncValue.when(
        data: (todo) {
          if (todo == null) {
            return const Center(child: Text('タスクが見つかりません'));
          }
          final createdAt = todo.createdAt.toDate();
          String completedByText = '';
          if (todo.isDone && todo.completedBy != null) {
            final completer = members.firstWhere(
              (m) => m.uid == todo.completedBy,
            );
            completedByText = ' by ${completer.name}';
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                todo.content,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('作成日'),
                subtitle: Text(
                  DateFormat('yyyy/MM/dd HH:mm').format(createdAt),
                ),
              ),
              if (todo.isDone && todo.completedAt != null)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('完了日'),
                  subtitle: Text(
                    '${DateFormat('yyyy/MM/dd HH:mm').format(todo.completedAt!.toDate())}$completedByText',
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}
