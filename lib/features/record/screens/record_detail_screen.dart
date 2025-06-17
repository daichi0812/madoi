// lib/features/record/screens/record_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:madoi/features/record/providers/record_providers.dart';

class RecordDetailScreen extends ConsumerWidget {
  final String workspaceId;
  final String vehicleId;
  final String recordId;

  const RecordDetailScreen({
    super.key,
    required this.workspaceId,
    required this.vehicleId,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから単一のrecordを取得する
    final recordData = ref.watch(
      recordDetailProvider(
        RecordDetailProviderArgs(
          workspaceId: workspaceId,
          vehicleId: vehicleId,
          recordId: recordId,
        ),
      ),
    );

    return Scaffold(
      // AppBarをScaffoldの中に移動し、タイトルも動的に設定
      appBar: AppBar(
        title: Text(
          recordData.value != null
              ? DateFormat(
                  'yyyy/MM/dd',
                ).format(recordData.value!.recordDate.toDate())
              : '詳細',
        ),
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 編集画面へ遷移
              context.go(
                '/workspace/$workspaceId/vehicle/$vehicleId/record/$recordId/edit',
              );
            },
          ),
        ],
      ),
      // .whenを使って、データの状態に応じて表示を切り替える
      body: recordData.when(
        data: (record) {
          if (record == null) {
            return const Center(child: Text('記録が見つかりません'));
          }
          // Markdown表示エリアをスクロール可能にする
          return Markdown(
            data: record.content,
            padding: const EdgeInsets.all(16.0),
            selectable: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}
