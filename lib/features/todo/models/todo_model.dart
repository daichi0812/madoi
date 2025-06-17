// lib/features/todo/models/todo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String content;
  final bool isCompleted;
  final Timestamp createdAt;
  final String vehicleId; // どの車両のToDoか
  final String workspaceId; // どのワークスペースに属しているか

  TodoModel({
    required this.id,
    required this.content,
    required this.isCompleted,
    required this.createdAt,
    required this.vehicleId,
    required this.workspaceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'vehicleId': vehicleId,
      'workspaceId': workspaceId,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      vehicleId: map['vehicleId'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
    );
  }
}
