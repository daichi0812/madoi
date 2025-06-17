// lib/features/record/providers/record_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/repositories/record_repository.dart';

// Repository
final recordRepositoryProvider = Provider((ref) => RecordRepository());

// 記録一覧を取得するProvider.family
// 引数を複数渡すため、RecordTypeとvehicleIdをMapで受け取る
final recordsProvider =
    StreamProvider.family<List<RecordModel>, Map<String, dynamic>>((ref, args) {
      final vehicleId = args['vehicleId'] as String;
      final type = args['type'] as RecordType;
      return ref
          .watch(recordRepositoryProvider)
          .getRecordsStream(vehicleId: vehicleId, type: type);
    });
