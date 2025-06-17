// lib/common/router/router.dart

import "dart:async";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/auth/screens/login_screen.dart';
import 'package:madoi/features/home/screens/main_screen.dart';

// go_routerのインスタンスをシングルトンで提供するProvider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // アプリの初期表示パス
    initialLocation: '/login',

    // ルートの定義
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
    ],

    // リダイレクトロジック
    redirect: (BuildContext context, GoRouterState state) {
      // 現在のパス
      final location = state.matchedLocation;

      // 認証状態のチェック (authState.value が null でなければログインしている)
      final isLoggedIn = ref.read(authStateProvider).value != null;

      // ログインしておらず、かつログインページ以外にアクセスしようとしている場合
      if (!isLoggedIn && location != '/login') {
        // ログインページに強制的にリダイレクト
        return '/login';
      }

      // ログイン済みで、かつログインページにアクセスしようとしている場合
      if (isLoggedIn && location == '/login') {
        // ホームページにリダイレクト
        return '/';
      }

      // 上記の条件に当てはまらない場合は、リダイレクトしない
      return null;
    },

    // authStateProvider の状態が変わるたびにリダイレクトを再評価する
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStateProvider.stream),
    ),
  );
});

// StreamをListenableに変換してGoRouterに状態変化を通知するためのヘルパークラス
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
