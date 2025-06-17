// lib/features/record/providers/record_providers.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/repositories/record_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

// ★★★ 1. 引数用の専用クラスを作成 ★★★
class RecordsProviderArgs extends Equatable {
  final String vehicleId;
  final RecordType type;

  const RecordsProviderArgs({required this.vehicleId, required this.type});

  @override
  List<Object?> get props => [vehicleId, type];
}

// Repository (変更なし)
final recordRepositoryProvider = Provider((ref) => RecordRepository());

// ★★★ 2. recordsProviderの定義を修正 ★★★
final recordsProvider =
    StreamProvider.family<List<RecordModel>, RecordsProviderArgs>((ref, args) {
      // Map<String, dynamic> ではなく RecordsProviderArgs を使う
      final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;

      if (activeWorkspaceId == null) {
        return Stream.value([]);
      }

      return ref
          .watch(recordRepositoryProvider)
          .getRecordsStream(
            vehicleId: args.vehicleId, // args.vehicleId でアクセス
            type: args.type, // args.type でアクセス
            workspaceId: activeWorkspaceId,
          );
    });

// Controller Provider
final recordControllerProvider = StateNotifierProvider<RecordController, bool>((
  ref,
) {
  return RecordController(
    recordRepository: ref.watch(recordRepositoryProvider),
  );
});

class RecordController extends StateNotifier<bool> {
  final RecordRepository _recordRepository;

  RecordController({required RecordRepository recordRepository})
    : _recordRepository = recordRepository,
      super(false); // 初期状態: not loading

  Future<void> addRecord({
    required BuildContext context,
    required String content,
    required RecordType type,
    required String vehicleId,
    required String workspaceId,
  }) async {
    state = true;
    try {
      await _recordRepository.addRecord(
        content: content,
        type: type,
        vehicleId: vehicleId,
        workspaceId: workspaceId,
      );
    } catch (e) {
      log('記録追加エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${e.toString()}')));
      }
    } finally {
      state = false;
    }
  }
}
