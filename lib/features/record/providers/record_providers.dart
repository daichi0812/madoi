// lib/features/record/providers/record_providers.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/repositories/record_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

// Repository
final recordRepositoryProvider = Provider((ref) => RecordRepository());

// 記録一覧を取得するProvider.family
// 引数を複数渡すため、RecordTypeとvehicleIdをMapで受け取る
final recordsProvider =
    StreamProvider.family<List<RecordModel>, Map<String, dynamic>>((ref, args) {
      final vehicleId = args['vehicleId'] as String;
      final type = args['type'] as RecordType;
      // アクティブなワークスペースIDを取得
      final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;

      if (activeWorkspaceId == null) {
        return Stream.value([]);
      }

      return ref
          .watch(recordRepositoryProvider)
          .getRecordsStream(
            vehicleId: vehicleId,
            type: type,
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
