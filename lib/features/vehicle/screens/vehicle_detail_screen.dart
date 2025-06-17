// lib/features/vehicle/screens/vehicle_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/workspace/providers/workspace_providers.dart';
import 'package:madoi/features/vehicle/providers/vehicle_providers.dart';
import 'package:madoi/features/todo/widgets/todo_tab_view.dart';
import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/widgets/record_tab_view.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // アクティブなワークスペースの情報を監視する
    final activeWorkspaceAsyncValue = ref.watch(activeWorkspaceProvider);

    // workspaceの読み込み状態に応じてUIを切り替える
    return activeWorkspaceAsyncValue.when(
      data: (activeWorkspace) {
        // ワークスペース情報がなければエラー表示
        if (activeWorkspace == null) {
          return const Scaffold(
            body: Center(child: Text('アクティブなワークスペースが見つかりません。')),
          );
        }

        // ★ ワークスペース情報が取得できた後で、車両詳細のProviderを呼び出す
        final vehicleData = ref.watch(
          vehicleDetailProvider((activeWorkspace.id, vehicleId)),
        );

        return DefaultTabController(
          length: 3,
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
                TodoTabView(vehicleId: vehicleId),
                RecordTabView(
                  vehicleId: vehicleId,
                  recordType: RecordType.maintenance,
                ),
                RecordTabView(
                  vehicleId: vehicleId,
                  recordType: RecordType.setting,
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('エラーが発生しました: $err'))),
    );
  }
}
