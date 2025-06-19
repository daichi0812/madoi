// lib/features/chat/repositories/chat_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/common/models/user_model.dart';
import 'package:madoi/features/chat/models/channel_model.dart';
import 'package:madoi/features/chat/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // チャンネル一覧を取得
  Stream<List<ChannelModel>> getChannelsStream(String workspaceId) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('channels')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChannelModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // 新しいチャンネルを作成
  Future<void> createChannel({
    required String name,
    required String workspaceId,
    required String creatorId,
  }) async {
    final newChannelRef = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('channels')
        .doc();
    final newChannel = ChannelModel(
      id: newChannelRef.id,
      name: name,
      workspaceId: workspaceId,
      creatorId: creatorId,
      createdAt: Timestamp.now(),
      lastMessageAt: Timestamp.now(),
    );
    await newChannelRef.set(newChannel.toMap());
  }

  // チャンネル詳細を取得
  Stream<ChannelModel?> getChannelStream(String workspaceId, String channelId) {
    return _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("channels")
        .doc(channelId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return ChannelModel.fromMap(snapshot.data()!);
          }
          return null;
        });
  }

  // メッセージ一覧を取得
  Stream<List<MessageModel>> getMessagesStream(
    String workspaceId,
    String channelId,
  ) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // 新しいメッセージを送信
  Future<void> sendMessage({
    required String workspaceId,
    required String channelId,
    required String text,
    required UserModel sender,
  }) async {
    final newMessageRef = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .doc();

    final newMessage = MessageModel(
      id: newMessageRef.id,
      channelId: channelId,
      senderId: sender.uid,
      text: text,
      createdAt: Timestamp.now(),
      senderName: sender.name,
      senderProfilePic: sender.profilePic,
    );

    // バッチ処理でメッセージ追加とチャンネル更新をアトミックに行う
    final batch = _firestore.batch();

    batch.set(newMessageRef, newMessage.toMap());

    final channelRef = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('channels')
        .doc(channelId);

    batch.update(channelRef, {
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
    });

    await batch.commit();
  }
}
