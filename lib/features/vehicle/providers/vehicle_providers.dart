// lib/features/vehicle/providers/vehicle_providers.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/vehicle/models/vehicle_model.dart';
import 'package:madoi/features/vehicle/repositories/vehicle_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

// Repository
final vehicleRepositoryProvider = Provider((ref) => VehicleRepository());

// 現在のワークスペースの車両一覧を取得するStreamProvider
final vehiclesProvider = StreamProvider<List<VehicleModel>>((ref) {
  final activeWorkspace = ref.watch(activeWorkspaceProvider).value;
  if (activeWorkspace == null) {
    return Stream.value([]);
  }
  return ref
      .watch(vehicleRepositoryProvider)
      .getVehiclesStream(activeWorkspace.id);
});

// IDを引数に取り、単一の車両データを取得するProvider.family
final vehicleDetailProvider = StreamProvider.family<VehicleModel?, String>((
  ref,
  vehicleId,
) {
  return ref.watch(vehicleRepositoryProvider).getVehicleStream(vehicleId);
});

// Controller Provider
final vehicleControllerProvider =
    StateNotifierProvider<VehicleController, bool>((ref) {
      return VehicleController(
        vehicleRepository: ref.watch(vehicleRepositoryProvider),
        ref: ref,
      );
    });

class VehicleController extends StateNotifier<bool> {
  final VehicleRepository _vehicleRepository;
  final Ref _ref;

  VehicleController({
    required VehicleRepository vehicleRepository,
    required Ref ref,
  }) : _vehicleRepository = vehicleRepository,
       _ref = ref,
       super(false); // 初期状態: not loading

  Future<void> addVehicle({
    required BuildContext context,
    required String name,
    required String nickname,
  }) async {
    state = true; // ローディング開始
    final workspaceId = _ref.read(activeWorkspaceProvider).value?.id;
    if (workspaceId == null) {
      state = false;
      log('アクティブなワークスペースがありません');
      return;
    }

    try {
      await _vehicleRepository.addVehicle(
        name: name,
        nickname: nickname,
        workspaceId: workspaceId,
      );
    } catch (e) {
      log('車両追加エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${e.toString()}')));
      }
    } finally {
      state = false; // ローディング終了
    }
  }
}
