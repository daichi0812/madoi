// lib/features/workspace/providers/workspace_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

import 'package:madoi/common/models/user_model.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/workspace/repositories/workspace_repository.dart';
import 'package:madoi/features/workspace/models/workspace_model.dart';

// --- Repository Provider ---
final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepository();
});

// --- Controller Provider ---
final workspaceControllerProvider =
    StateNotifierProvider<WorkspaceController, bool>((ref) {
      return WorkspaceController(
        workspaceRepository: ref.watch(workspaceRepositoryProvider),
        ref: ref,
      );
    });

// アクティブなワークスペースの情報を取得するProvider
final activeWorkspaceProvider = StreamProvider<WorkspaceModel?>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  if (userData == null || userData.memberOfWorkspaces.isEmpty) {
    return Stream.value(null);
  }
  // とりあえず最初のワークスペースをアクティブとする
  final activeWorkspaceId = userData.memberOfWorkspaces[0];
  return ref
      .watch(workspaceRepositoryProvider)
      .getWorkspaceStream(activeWorkspaceId);
});

// 現在のワークスペースに参加しているメンバーのユーザー情報を取得するProvider
final workspaceMembersProvider = StreamProvider<List<UserModel>>((ref) {
  // 現在アクティブなワークスペースの情報を監視
  final activeWorkspace = ref.watch(activeWorkspaceProvider).value;

  // ワークスペース情報がない、またはメンバーがいない場合は空のリストを返す
  if (activeWorkspace == null || activeWorkspace.members.isEmpty) {
    return Stream.value([]);
  }

  // AuthRepositoryのメソッドを呼び出してメンバーの情報を取得
  return ref
      .watch(authRepositoryProvider)
      .getUsersStream(activeWorkspace.members);
});

// 状態としてローディング中(true)か否(false)かを持つStateNotifier
class WorkspaceController extends StateNotifier<bool> {
  final WorkspaceRepository _workspaceRepository;
  final Ref _ref;

  WorkspaceController({
    required WorkspaceRepository workspaceRepository,
    required Ref ref,
  }) : _workspaceRepository = workspaceRepository,
       _ref = ref,
       super(false); // 初期値はローディング中でない(false)

  Future<void> createWorkspace(String name) async {
    state = true; // ローディング開始
    final user = _ref.read(authStateProvider).value;
    if (user == null) {
      state = false;
      return;
    }
    try {
      await _workspaceRepository.createWorkspace(name, user.uid);
    } catch (e) {
      log('ワークスペース作成エラー: $e');
    } finally {
      // finalyブロックで必ずローディングを終了させる
      state = false;
    }
  }

  Future<bool> joinWorkspace(BuildContext context, String workspaceId) async {
    state = true; // ローディング開始
    final user = _ref.read(authStateProvider).value;
    if (user == null) {
      state = false;
      return false;
    }
    try {
      // 招待コード(workspaceId)とユーザーIDを渡して参加処理を実行
      await _workspaceRepository.joinWorkspace(workspaceId, user.uid);
      return true;
    } catch (e, s) {
      // エラーをログに出力
      log('ワークスペース参加エラー: $e');
      log('スタックトレース: $s'); // スタックトレースをログに出力
      // エラー時に画面にスナックバーでメッセージを表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', "")),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      state = false;
      return false;
    }
  }
}
