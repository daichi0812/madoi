// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceData = ref.watch(activeWorkspaceProvider);

    return Scaffold(
      body: workspaceData.when(
        data: (workspace) {
          if (workspace == null) {
            return const Center(child: Text('ワークスペース情報がありません'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text('ワークスペース名'),
                subtitle: Text(workspace.name),
              ),
              ListTile(
                title: const Text('招待コード（ワークスペースID）'),
                subtitle: Text(workspace.id),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: workspace.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('招待コードをコピーしました')),
                    );
                  },
                ),
              ),
              // 他にもメンバー管理などの設定項目を追加できる
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}
