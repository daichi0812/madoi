// lib/features/todo/screens/add_edit_todo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madoi/features/todo/providers/todo_providers.dart';

class AddEditTodoScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String vehicleId;
  final String? todoId; // これがnullでなければ編集モード

  const AddEditTodoScreen({
    super.key,
    required this.workspaceId,
    required this.vehicleId,
    this.todoId,
  });

  @override
  ConsumerState<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends ConsumerState<AddEditTodoScreen> {
  final _contentController = TextEditingController();
  bool get _isEditMode => widget.todoId != null;

  @override
  void initState() {
    super.initState();
    // 編集モードの場合、既存のデータを読み込んでTextFieldにセットする
    if (_isEditMode) {
      ref
          .read(
            todoDetailProvider(
              TodoDetailProviderArgs(
                workspaceId: widget.workspaceId,
                vehicleId: widget.vehicleId,
                todoId: widget.todoId!,
              ),
            ),
          )
          .whenData((todo) {
            if (todo != null) {
              _contentController.text = todo.content;
            }
          });
    }
  }

  void _saveTodo() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    bool isSuccess = false;
    final controller = ref.read(todoControllerProvider.notifier);

    if (_isEditMode) {
      // 編集のロジック
      isSuccess = await controller.updateTodo(
        context: context,
        todoId: widget.todoId!,
        content: content,
        vehicleId: widget.vehicleId,
        workspaceId: widget.workspaceId,
      );
    } else {
      // 新規作成のロジック
      isSuccess = await controller.addTodo(
        context: context,
        content: content,
        vehicleId: widget.vehicleId,
        workspaceId: widget.workspaceId,
      );
    }

    if (mounted && isSuccess) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(todoControllerProvider);
    final title = _isEditMode ? 'ToDoを編集' : 'ToDoを追加';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _saveTodo,
            icon: const Icon(Icons.done),
            tooltip: '保存',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'タスクの内容を入力...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                autofocus: true,
              ),
      ),
    );
  }
}
