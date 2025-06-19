// lib/features/chat/screens/create_channel_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madoi/features/chat/providers/chat_providers.dart';

class CreateChannelScreen extends ConsumerStatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  ConsumerState<CreateChannelScreen> createState() =>
      _CreateChannelScreenState();
}

class _CreateChannelScreenState extends ConsumerState<CreateChannelScreen> {
  final _nameController = TextEditingController();

  void _createChannel() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final isSuccess = await ref
          .read(chatControllerProvider.notifier)
          .createChannel(context: context, name: name);
      if (mounted && isSuccess) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(chatControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('新しいチャンネルを作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'チャンネル名',
                prefixText: '# ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _createChannel,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('作成'),
            ),
          ],
        ),
      ),
    );
  }
}
