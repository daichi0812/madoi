// lib/features/record/widgets/record_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/providers/record_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class RecordTabView extends ConsumerWidget {
  final String vehicleId;
  final RecordType recordType;

  const RecordTabView({
    super.key,
    required this.vehicleId,
    required this.recordType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在のワークスペースIDを取得
    final activeWorkspaceId = ref.watch(activeWorkspaceProvider).value?.id;
    final records = ref.watch(
      recordsProvider(
        RecordsProviderArgs(vehicleId: vehicleId, type: recordType),
      ),
    );

    return Scaffold(
      body: records.when(
        data: (recordList) {
          if (recordList.isEmpty) {
            return const Center(child: Text('まだ記録がありません'));
          }
          return ListView.builder(
            itemCount: recordList.length,
            itemBuilder: (context, index) {
              final record = recordList[index];
              return ListTile(
                title: Text(
                  DateFormat('yyyy/MM/dd').format(record.recordDate.toDate()),
                ),
                subtitle: Text(
                  record.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // nullチェックを追加
                  if (activeWorkspaceId != null) {
                    // 新しいルートに、全てのIDを渡して遷移
                    context.go(
                      '/workspace/$activeWorkspaceId/vehicle/$vehicleId/record/${record.id}',
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 記録追加画面へ遷移
          context.go('/vehicle/$vehicleId/add-record/${recordType.name}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
