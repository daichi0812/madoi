// lib/features/record/widgets/record_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/providers/record_providers.dart';

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
    final records = ref.watch(
      recordsProvider({'vehicleId': vehicleId, 'type': recordType}),
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
                  context.go('/record/${record.id}');
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
