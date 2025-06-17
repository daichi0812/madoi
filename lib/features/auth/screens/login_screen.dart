// login_screen.dart
// UI画面、ここではConsumerWidgetを使い、RiverpodのProviderにアクセスできるようにする

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('madoi へようこそ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('まずはログインしてください', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.login), // ここをGoogleアイコンなどに変更すると良い
              label: const Text('Googleでサインイン'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                // ボタンが押されたらログイン処理を呼び出す
                try {
                  await ref.read(loginProvider).signInWithGoogle();
                  // 成功した場合、次のステップの画面振り分けによって自動でメイン画面に遷移します。
                } catch (e) {
                  // エラーが発生した場合の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ログインに失敗しました: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
