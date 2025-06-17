// lib/features/record/screens/add_edit_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madoi/features/record/models/record_model.dart';
import 'package:madoi/features/record/providers/record_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class AddEditRecordScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final RecordType recordType;
  const AddEditRecordScreen({
    super.key,
    required this.vehicleId,
    required this.recordType,
  });

  @override
  ConsumerState<AddEditRecordScreen> createState() =>
      _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends ConsumerState<AddEditRecordScreen> {
  final _contentController = TextEditingController();

  void _saveRecord() async {
    final content = _contentController.text.trim();
    final workspaceId = ref.read(activeWorkspaceProvider).value?.id;

    if (content.isNotEmpty && workspaceId != null) {
      await ref
          .read(recordControllerProvider.notifier)
          .addRecord(
            context: context,
            content: content,
            type: widget.recordType,
            vehicleId: widget.vehicleId,
            workspaceId: workspaceId,
          );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(recordControllerProvider);
    final title = widget.recordType == RecordType.maintenance
        ? '整備記録を追加'
        : 'セッティング記録を追加';

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
                  hintText: 'Markdown形式で記録を入力...',
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
