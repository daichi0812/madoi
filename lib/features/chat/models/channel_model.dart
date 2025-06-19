// lib/features/chat/models/channel_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelModel {
  final String id;
  final String name;
  final String workspaceId;
  final String creatorId;
  final Timestamp createdAt;
  final String? lastMessage;
  final Timestamp? lastMessageAt;

  ChannelModel({
    required this.id,
    required this.name,
    required this.workspaceId,
    required this.creatorId,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'workspaceId': workspaceId,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
    };
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      lastMessage: map['lastMessage'],
      lastMessageAt: map['lastMessageAt'],
    );
  }
}
