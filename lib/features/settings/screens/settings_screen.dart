// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ワークスペースの情報を監視
    final workspaceData = ref.watch(activeWorkspaceProvider);
    // ワークスペースのメンバー情報を監視
    final membersData = ref.watch(workspaceMembersProvider);

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
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text(
                  '参加中のメンバー (${membersData.value?.length ?? 0})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // ★ メンバー一覧を非同期で表示
              membersData.when(
                data: (members) {
                  if (members.isEmpty) {
                    return const ListTile(title: Text('メンバーがいません'));
                  }
                  // ListViewの中に直接Widgetのリストを展開
                  return Column(
                    children: members.map((member) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(member.profilePic),
                        ),
                        title: Text(member.name),
                        subtitle: Text(member.email),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: const Text('メンバーの読み込みに失敗しました'),
                  subtitle: Text(err.toString()),
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
