// lib/common/router/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/auth/screens/login_screen.dart';
import 'package:madoi/features/home/screens/main_screen.dart';
import "package:madoi/features/workspace/screens/create_workspace_screen.dart";
import 'package:madoi/features/vehicle/screens/vehicle_detail_screen.dart';
import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/screens/add_edit_record_screen.dart';
import 'package:madoi/features/record/screens/record_detail_screen.dart';
import 'package:madoi/features/todo/screens/todo_detail_screen.dart';
import 'package:madoi/features/todo/screens/add_edit_todo_screen.dart';
import 'package:madoi/features/chat/screens/create_channel_screen.dart';
import 'package:madoi/features/chat/screens/chat_screen.dart';

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
        path: '/create-channel',
        name: 'create-channel',
        builder: (context, state) => const CreateChannelScreen(),
      ),
      GoRoute(
        path: '/workspace/:workspaceId/channel/:channelId',
        name: 'chat',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final channelId = state.pathParameters['channelId']!;
          return ChatScreen(workspaceId: workspaceId, channelId: channelId);
        },
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
      GoRoute(
        path: '/workspace/:workspaceId/vehicle/:vehicleId/add-todo',
        name: 'add-todo',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final vehicleId = state.pathParameters['vehicleId']!;
          return AddEditTodoScreen(
            workspaceId: workspaceId,
            vehicleId: vehicleId,
          );
        },
      ),
      GoRoute(
        path: '/workspace/:workspaceId/vehicle/:vehicleId/todo/:todoId',
        name: 'todo-detail',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final vehicleId = state.pathParameters['vehicleId']!;
          final todoId = state.pathParameters['todoId']!;
          return TodoDetailScreen(
            workspaceId: workspaceId,
            vehicleId: vehicleId,
            todoId: todoId,
          );
        },
      ),
      GoRoute(
        path: '/workspace/:workspaceId/vehicle/:vehicleId/todo/:todoId/edit',
        name: 'edit-todo',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final vehicleId = state.pathParameters['vehicleId']!;
          final todoId = state.pathParameters['todoId']!;
          return AddEditTodoScreen(
            workspaceId: workspaceId,
            vehicleId: vehicleId,
            todoId: todoId, // 編集モード
          );
        },
      ),
      GoRoute(
        path:
            '/workspace/:workspaceId/vehicle/:vehicleId/add-record/:recordType',
        name: 'add-record',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId'];
          final vehicleId = state.pathParameters['vehicleId']!;
          final recordTypeString = state.pathParameters['recordType']!;
          final recordType = RecordType.values.byName(recordTypeString);
          return AddEditRecordScreen(
            workspaceId: workspaceId!,
            vehicleId: vehicleId,
            recordType: recordType,
          );
        },
      ),
      GoRoute(
        path: '/workspace/:workspaceId/vehicle/:vehicleId/record/:recordId',
        name: 'record-detail',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final vehicleId = state.pathParameters['vehicleId']!;
          final recordId = state.pathParameters['recordId']!;
          return RecordDetailScreen(
            workspaceId: workspaceId,
            vehicleId: vehicleId,
            recordId: recordId,
          );
        },
      ),
      GoRoute(
        path:
            '/workspace/:workspaceId/vehicle/:vehicleId/record/:recordId/edit',
        name: 'edit-record',
        builder: (context, state) {
          final workspaceId = state.pathParameters['workspaceId']!;
          final vehicleId = state.pathParameters['vehicleId']!;
          final recordId = state.pathParameters['recordId']!;

          // AddEditRecordScreenに編集対象のrecordIdを渡す
          return AddEditRecordScreen(
            workspaceId: workspaceId,
            vehicleId: vehicleId,
            recordId: recordId, // ★ 編集モードであることを示すためにrecordIdを渡す
          );
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
