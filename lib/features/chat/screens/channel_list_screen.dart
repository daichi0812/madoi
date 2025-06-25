// lib/features/chat/screens/channel_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:madoi/features/chat/providers/chat_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class ChannelListScreen extends ConsumerWidget {
  const ChannelListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);
    final workspaceId = ref.watch(activeWorkspaceProvider).value?.id;

    return Scaffold(
      body: channelsAsync.when(
        data: (channels) {
          if (channels.isEmpty) {
            return const Center(
              child: Text(
                'チャンネルがありません。\n右下のボタンから作成しましょう！',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ListTile(
                title: Text(
                  '# ${channel.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  channel.lastMessage ?? 'まだメッセージはありません',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: channel.lastMessageAt != null
                    ? Text(
                        DateFormat(
                          'MM/dd HH:mm',
                        ).format(channel.lastMessageAt!.toDate()),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
                onTap: () {
                  if (workspaceId != null) {
                    context.push(
                      '/workspace/$workspaceId/channel/${channel.id}',
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
        heroTag: 'add-channel',
        onPressed: () {
          context.push('/create-channel');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
