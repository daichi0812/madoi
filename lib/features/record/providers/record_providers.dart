// lib/features/record/providers/record_providers.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/repositories/record_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

// 詳細画面用の引数クラスを作成
class RecordDetailProviderArgs extends Equatable {
  final String workspaceId;
  final String vehicleId;
  final String recordId;

  const RecordDetailProviderArgs({
    required this.workspaceId,
    required this.vehicleId,
    required this.recordId,
  });

  @override
  List<Object?> get props => [workspaceId, vehicleId, recordId];
}

//　引数用の専用クラスを作成
class RecordsProviderArgs extends Equatable {
  final String vehicleId;
  final RecordType type;

  const RecordsProviderArgs({required this.vehicleId, required this.type});

  @override
  List<Object?> get props => [vehicleId, type];
}

// Repository
final recordRepositoryProvider = Provider((ref) => RecordRepository());

// recordsProviderの定義
final recordsProvider =
    StreamProvider.family<List<RecordModel>, RecordsProviderArgs>((ref, args) {
      // RecordsProviderArgs を使う
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

//  単一の記録を取得するためのProvider.familyを追加
final recordDetailProvider =
    StreamProvider.family<RecordModel?, RecordDetailProviderArgs>((ref, args) {
      return ref
          .watch(recordRepositoryProvider)
          .getRecordStream(
            workspaceId: args.workspaceId,
            vehicleId: args.vehicleId,
            recordId: args.recordId,
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

  Future<bool> addRecord({
    required BuildContext context,
    required String content,
    required RecordType type,
    required String vehicleId,
    required String workspaceId,
  }) async {
    state = true;
    bool isSuccess = false;
    try {
      await _recordRepository.addRecord(
        content: content,
        type: type,
        vehicleId: vehicleId,
        workspaceId: workspaceId,
      );
      isSuccess = true;
    } catch (e) {
      log('記録追加エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${e.toString()}')));
      }
      isSuccess = false;
    } finally {
      state = false;
    }
    return isSuccess;
  }

  // 記録を更新するメソッド
  Future<bool> updateRecord({
    required BuildContext context,
    required String recordId,
    required String content,
    required String workspaceId,
    required String vehicleId,
  }) async {
    state = true;
    bool isSuccess = false;
    try {
      await _recordRepository.updateRecord(
        content: content,
        workspaceId: workspaceId,
        vehicleId: vehicleId,
        recordId: recordId,
      );
      isSuccess = true;
    } catch (e) {
      log('記録更新エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${e.toString()}')));
      }
      isSuccess = false;
    } finally {
      state = false;
    }
    return isSuccess;
  }
}
