// lib/features/record/providers/record_providers.dart
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
