// lib/common/router/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/auth/screens/login_screen.dart';
import 'package:madoi/features/home/screens/main_screen.dart';
import "package:madoi/features/workspace/screens/create_workspace_screen.dart";
import 'package:madoi/features/vehicle/screens/vehicle_detail_screen.dart';

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
      GoRoute(
        path: "/create-workspace",
        name: 'create-workspace',
        builder: (context, state) => const CreateWorkspaceScreen(),
      ),
      GoRoute(
        path: '/vehicle/:vehicleId',
        name: 'vehicle-detail',
        builder: (context, state) {
          // パスからvehicleIdを取得
          final vehicleId = state.pathParameters['vehicleId']!;
          return VehicleDetailScreen(vehicleId: vehicleId);
        },
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
  );
});
