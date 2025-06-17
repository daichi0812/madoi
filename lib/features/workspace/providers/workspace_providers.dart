// lib/features/workspace/providers/workspace_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/workspace/repositories/workspace_repository.dart';

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
    if (user != null) {
      await _workspaceRepository.createWorkspace(name, user.uid);
    }
    state = false; // ローディング終了
  }
}
