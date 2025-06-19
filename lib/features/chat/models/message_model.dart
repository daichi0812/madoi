// lib/features/chat/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String channelId;
  final String senderId;
  final String text;
  final Timestamp createdAt;
  final String senderName;
  final String senderProfilePic;

  MessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.senderName,
    required this.senderProfilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channelId': channelId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt,
      'senderName': senderName,
      'senderProfilePic': senderProfilePic,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      channelId: map['channelId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      senderName: map['senderName'] ?? '',
      senderProfilePic: map['senderProfilePic'] ?? '',
    );
  }
}
