// lib/features/record/screens/add_edit_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/providers/record_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class AddEditRecordScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String vehicleId;
  final String? recordId;
  final RecordType? recordType;

  const AddEditRecordScreen({
    super.key,
    required this.workspaceId,
    required this.vehicleId,
    this.recordId,
    this.recordType,
  });

  @override
  ConsumerState<AddEditRecordScreen> createState() =>
      _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends ConsumerState<AddEditRecordScreen> {
  final _contentController = TextEditingController();
  bool get _isEditMode => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    // 編集モードの場合、既存のデータを読み込んでセットする
    if (_isEditMode) {
      ref
          .read(
            recordDetailProvider(
              RecordDetailProviderArgs(
                workspaceId: widget.workspaceId,
                vehicleId: widget.vehicleId,
                recordId: widget.recordId!,
              ),
            ),
          )
          .whenData((record) {
            if (record != null) {
              _contentController.text = record.content;
            }
          });
    }
  }

  void _saveRecord() async {
    final content = _contentController.text.trim();
    final workspaceId = ref.read(activeWorkspaceProvider).value?.id;

    if (content.isNotEmpty && workspaceId != null) {
      bool isSuccess = false;
      if (_isEditMode) {
        // 編集モードの処理
        isSuccess = await ref
            .read(recordControllerProvider.notifier)
            .updateRecord(
              content: content,
              context: context,
              recordId: widget.recordId!,
              workspaceId: widget.workspaceId,
              vehicleId: widget.vehicleId,
            );
      } else {
        // 新規作成モードの処理
        isSuccess = await ref
            .read(recordControllerProvider.notifier)
            .addRecord(
              context: context,
              content: content,
              type: widget.recordType!,
              vehicleId: widget.vehicleId,
              workspaceId: workspaceId,
            );
      }

      if (mounted && isSuccess) {
        context.pop();
        // context.go('/vehicle/${widget.vehicleId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(recordControllerProvider);
    final title = _isEditMode
        ? '記録を編集'
        : (widget.recordType == RecordType.maintenance
              ? '整備記録を追加'
              : 'セッティング記録を追加');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _saveRecord,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: '''
Markdown記法で記録を分かりやすく！

【入力例】
# オイル交換 (大きな見出し)
## フロントブレーキ (小さな見出し)

**ここを太文字に** して強調できます。
*ここはイタリック(斜体)に* なります。

- 箇条書きはハイフンとスペース
- このように項目を分けられます

1. 番号付きリストも使えます
2. 順番が大切な記録に便利です

---
↑ハイフン3つで区切り線が引けます
''',
                  border: InputBorder.none,
                ),
                maxLines: null, // 複数行入力
                expands: true, // 入力欄を全画面に広げる
                autofocus: true,
              ),
      ),
    );
  }
}
