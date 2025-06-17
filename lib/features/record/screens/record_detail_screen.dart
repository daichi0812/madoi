// lib/features/record/screens/record_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: あとで単一の記録を取得するProviderをインポート

class RecordDetailScreen extends ConsumerWidget {
  final String recordId;
  // TODO: 他に必要なIDも受け取る
  const RecordDetailScreen({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Providerから単一のrecordを取得する
    final recordContent = "# サンプル\n\n- これは\n- Markdownです"; // 仮のデータ

    return Scaffold(
      appBar: AppBar(title: const Text('記録詳細')),
      body: Markdown(
        data: recordContent,
        padding: const EdgeInsets.all(16.0),
        selectable: true, // テキスト選択を可能にする
      ),
    );
  }
}
