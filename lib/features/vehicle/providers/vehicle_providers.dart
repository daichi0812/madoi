// lib/features/vehicle/providers/vehicle_providers.dart
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
