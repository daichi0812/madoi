// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:madoi/common/router/router.dart";
import "package:madoi/features/auth/providers/auth_providers.dart";
import 'firebase_options.dart'; // flutterfire configureで生成されたファイル

void main() async {
  // main関数で非同期処理を呼び出すためのおまじない
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseの初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Riverpodを使うための設定
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // goRouterProviderを監視
    final router = ref.watch(goRouterProvider);
    //authStateProviderの状態を監視し、変更があればコールバックを実行
    ref.listen(authStateProvider, (_, __) {
      // 状態が変化したら（ログインやログアウト時など）go_routerにルートの再評価を促す
      router.refresh();
    });

    return MaterialApp.router(
      title: 'Madoi',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
