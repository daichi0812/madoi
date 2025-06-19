// lib/features/chat/providers/chat_providers.dart

import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/chat/models/channel_model.dart';
import 'package:madoi/features/chat/models/message_model.dart';
import 'package:madoi/features/chat/repositories/chat_repository.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

// --- Repository Provider ---
final chatRepositoryProvider = Provider((ref) => ChatRepository());

// --- Stream Providers ---

// チャンネル一覧
final channelsProvider = StreamProvider<List<ChannelModel>>((ref) {
  final workspaceId = ref.watch(activeWorkspaceProvider).value?.id;
  if (workspaceId == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).getChannelsStream(workspaceId);
});

// 引数用のクラス
class MessagesProviderArgs extends Equatable {
  final String workspaceId;
  final String channelId;

  const MessagesProviderArgs({
    required this.workspaceId,
    required this.channelId,
  });

  @override
  List<Object?> get props => [workspaceId, channelId];
}

// メッセージ一覧
final messagesProvider =
    StreamProvider.family<List<MessageModel>, MessagesProviderArgs>((
      ref,
      args,
    ) {
      return ref
          .watch(chatRepositoryProvider)
          .getMessagesStream(args.workspaceId, args.channelId);
    });

// --- Controller Provider ---
final chatControllerProvider = StateNotifierProvider<ChatController, bool>((
  ref,
) {
  return ChatController(
    chatRepository: ref.watch(chatRepositoryProvider),
    ref: ref,
  );
});

class ChatController extends StateNotifier<bool> {
  final ChatRepository _chatRepository;
  final Ref _ref;

  ChatController({required ChatRepository chatRepository, required Ref ref})
    : _chatRepository = chatRepository,
      _ref = ref,
      super(false);

  Future<bool> createChannel({
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    bool isSuccess = false;
    final workspaceId = _ref.read(activeWorkspaceProvider).value?.id;
    final creatorId = _ref.read(currentUserDataProvider).value?.uid;

    if (workspaceId == null || creatorId == null) {
      log('ワークスペースまたはユーザー情報が取得できませんでした。');
      state = false;
      return false;
    }

    try {
      await _chatRepository.createChannel(
        name: name,
        workspaceId: workspaceId,
        creatorId: creatorId,
      );
      isSuccess = true;
    } catch (e) {
      log('チャンネル作成エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: ${e.toString()}')));
      }
    } finally {
      state = false;
    }
    return isSuccess;
  }

  Future<void> sendMessage({
    required String channelId,
    required String text,
  }) async {
    final workspaceId = _ref.read(activeWorkspaceProvider).value?.id;
    final sender = _ref.read(currentUserDataProvider).value;

    if (workspaceId == null || sender == null || text.trim().isEmpty) {
      return;
    }

    try {
      await _chatRepository.sendMessage(
        workspaceId: workspaceId,
        channelId: channelId,
        text: text.trim(),
        sender: sender,
      );
    } catch (e) {
      log('メッセージ送信エラー: $e');
    }
  }
}
