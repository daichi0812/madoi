// lib/features/workspace/screens/create_workspace_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class CreateWorkspaceScreen extends ConsumerStatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  ConsumerState<CreateWorkspaceScreen> createState() =>
      _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState extends ConsumerState<CreateWorkspaceScreen> {
  final TextEditingController _nameController = TextEditingController();

  void createWorkspace() async {
    final workspaceName = _nameController.text.trim();
    if (workspaceName.isNotEmpty) {
      // コントローラーのメソッドを呼び出す
      await ref
          .read(workspaceControllerProvider.notifier)
          .createWorkspace(workspaceName);

      // 成功したら前の画面に戻る
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しいワークスペースを作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ワークスペース名',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: ref.watch(workspaceControllerProvider)
                  ? null
                  : createWorkspace,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: ref.watch(workspaceControllerProvider)
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('作成'),
            ),
          ],
        ),
      ),
    );
  }
}
