// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面のテーマを取得
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // ★ AppBarを削除し、より没入感のあるデザインに
      body: SafeArea(
        child: Center(
          // ★ 全体に余白を追加
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // 子ウィジェットを横幅いっぱいに広げる
              children: [
                // ★ 1. アプリアイコンやイラストを追加
                Icon(
                  Icons.group_work_outlined, // アプリのロゴやイラストに置き換える
                  size: 120,
                  color: colors.primary,
                ),
                const SizedBox(height: 24),

                // ★ 2. テキストのスタイルを調整
                Text(
                  'madoiへようこそ',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'あなたの部活動を、もっとスマートに。',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // ★ 3. Googleサインインボタンのデザインを改善
                ElevatedButton.icon(
                  icon: Image.network(
                    'https://www.gstatic.com/marketing-cms/assets/images/d5/dc/cfe9ce8b4425b410b49b7f2dd3f3/g.webp=s96-fcrop64=1,00000000ffffffff-rw',
                    height: 24.0,
                  ),
                  label: const Text('Googleでサインイン'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // テキストの色
                    backgroundColor: Colors.white, // ボタンの背景色
                    minimumSize: const Size(double.infinity, 50), // ボタンの最小サイズ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!), // 枠線
                    ),
                    elevation: 1,
                  ),
                  onPressed: () async {
                    try {
                      await ref.read(loginProvider).signInWithGoogle();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ログインに失敗しました: ${e.toString()}'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
