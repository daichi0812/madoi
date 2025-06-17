// lib/features/home/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/settings/screens/settings_screen.dart';
import 'package:madoi/features/todo/screens/todo_screen.dart';
import 'package:madoi/features/vehicle/screens/vehicle_screen.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  // ★ TodoScreenのプレースホルダーを削除し、実際の画面リストを定義
  final List<Widget> _pages = [const VehicleScreen(), const SettingsScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(currentUserDataProvider);

    return userData.when(
      data: (user) {
        if (user == null || user.memberOfWorkspaces.isEmpty) {
          return const NoWorkspaceScreen();
        }

        // ★★★ 1. AppBarの改善 ★★★
        // アクティブなワークスペースの情報を取得してAppBarのタイトルに表示
        final activeWorkspace = ref.watch(activeWorkspaceProvider);

        return Scaffold(
          appBar: AppBar(
            // ワークスペース名を表示、ローディング中は'...'を表示
            title: Text(
              activeWorkspace.when(
                data: (ws) => ws?.name ?? 'ワークスペース',
                loading: () => '...',
                error: (e, s) => 'エラー',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
          body: IndexedStack(index: _selectedIndex, children: _pages),
          // ★★★ 2. BottomNavigationBarの改善 ★★★
          bottomNavigationBar: BottomNavigationBar(
            onTap: _onItemTapped,
            currentIndex: _selectedIndex,
            // 選択中のアイテムの色を指定
            selectedItemColor: Theme.of(context).colorScheme.primary,
            // 選択されていないアイテムの色を指定
            unselectedItemColor: Colors.grey,
            // ★ ToDoタブを削除し、車両と設定のみに
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                label: '車両',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("エラーが発生しました: ${err.toString()}"))),
    );
  }
}

// ★★★ 3. NoWorkspaceScreenのUI改善 ★★★
class NoWorkspaceScreen extends ConsumerWidget {
  const NoWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.group_work_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'madoi へようこそ！',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '最初のステップとして、\nワークスペースを作成するか、\n既存のワークスペースに参加してください。',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  context.go('/create-workspace');
                },
                child: const Text('新しいワークスペースを作成'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const JoinWorkspaceDialog(),
                  );
                },
                child: const Text('招待コードで参加'),
              ),
            ],
          ),
        ),
      ),
      // ログアウトボタンを右上に配置
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.logout),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

// ★ ファイルの下部にダイアログのWidgetを追加
class JoinWorkspaceDialog extends ConsumerStatefulWidget {
  const JoinWorkspaceDialog({super.key});

  @override
  ConsumerState<JoinWorkspaceDialog> createState() =>
      _JoinWorkspaceDialogState();
}

class _JoinWorkspaceDialogState extends ConsumerState<JoinWorkspaceDialog> {
  final TextEditingController _codeController = TextEditingController();

  void joinWorkspace() async {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      await ref
          .read(workspaceControllerProvider.notifier)
          .joinWorkspace(context, code);
      if (mounted) {
        Navigator.of(context).pop();
        // context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ローディング状態をProviderから監視
    final isLoading = ref.watch(workspaceControllerProvider);

    return AlertDialog(
      title: const Text('ワークスペースに参加'),
      content: TextField(
        controller: _codeController,
        decoration: const InputDecoration(labelText: '招待コード'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          // ローディング中はボタンを押せなくする
          onPressed: isLoading ? null : joinWorkspace,
          // ローディング中はインジケーターを表示
          child: isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('参加'),
        ),
      ],
    );
  }
}
