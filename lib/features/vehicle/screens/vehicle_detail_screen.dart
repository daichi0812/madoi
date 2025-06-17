// lib/features/vehicle/screens/vehicle_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/vehicle/providers/vehicle_providers.dart';
import 'package:madoi/features/todo/widgets/todo_tab_view.dart';
import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/widgets/record_tab_view.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // vehicleDetailProviderを呼び出し
    final vehicleData = ref.watch(vehicleDetailProvider(vehicleId));

    // TabControllerを使ってタブ付きの画面を簡単に作成
    return DefaultTabController(
      length: 3, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: vehicleData.when(
            data: (vehicle) => Text(vehicle?.name ?? '詳細'),
            loading: () => const Text('...'),
            error: (err, stack) => const Text('エラー'),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.checklist), text: 'ToDo'),
              Tab(icon: Icon(Icons.build), text: '整備記録'),
              Tab(icon: Icon(Icons.tune), text: 'セッティング'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 各タブに表示する仮のコンテンツ
            TodoTabView(vehicleId: vehicleId),
            // 整備記録タブ
            RecordTabView(
              vehicleId: vehicleId,
              recordType: RecordType.maintenance,
            ),
            // セッティング記録タブ
            RecordTabView(vehicleId: vehicleId, recordType: RecordType.setting),
          ],
        ),
      ),
    );
  }
}
