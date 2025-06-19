// lib/features/chat/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/chat/models/message_model.dart';
import 'package:madoi/features/chat/providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String channelId;
  const ChatScreen({
    super.key,
    required this.workspaceId,
    required this.channelId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    ref
        .read(chatControllerProvider.notifier)
        .sendMessage(
          channelId: widget.channelId,
          text: _messageController.text,
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesProvider(
        MessagesProviderArgs(
          workspaceId: widget.workspaceId,
          channelId: widget.channelId,
        ),
      ),
    );

    // AppBarのタイトルのためにチャンネル情報を取得
    final channelAsync = ref.watch(
      channelDetailProvider(
        ChannelProviderArgs(
          workspaceId: widget.workspaceId,
          channelId: widget.channelId,
        ),
      ),
    );

    final currentUserId = ref.watch(currentUserDataProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(
        // チャンネル情報をAppBarのタイトルに表示
        title: channelAsync.when(
          data: (channel) =>
              Text(channel != null ? '# ${channel.name}' : 'チャット'),
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          error: (err, stack) => const Text('エラー'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('最初のメッセージを送信しよう！'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('エラー: $err')),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    // 自分のメッセージの場合
    if (isMe) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.black,
            ),
          ),
        ),
      );
    }
    // 他のユーザーのメッセージの場合
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プロフィール画像
            CircleAvatar(
              radius: 18,
              backgroundImage: message.senderProfilePic.isNotEmpty
                  ? NetworkImage(message.senderProfilePic)
                  : null,
              child: message.senderProfilePic.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
            // 名前とメッセージの吹き出し
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 送信者名
                  Text(
                    message.senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // メッセージの吹き出し
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'メッセージを入力',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
