// lib/features/todo/models/todo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final String id;
  final String content;
  final bool isDone;
  final String vehicleId;
  final String workspaceId;
  final Timestamp createdAt;
  final String? createdBy;
  final Timestamp? completedAt;

  const TodoModel({
    required this.id,
    required this.content,
    required this.isDone,
    required this.vehicleId,
    required this.workspaceId,
    required this.createdAt,
    this.createdBy,
    this.completedAt,
  });

  // copyWithメソッドを更新
  TodoModel copyWith({
    String? id,
    String? content,
    bool? isDone,
    String? vehicleId,
    String? workspaceId,
    Timestamp? createdAt,
    String? createdBy,
    Timestamp? completedAt,
    bool completedAtToNull = false,
  }) {
    return TodoModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      vehicleId: vehicleId ?? this.vehicleId,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      // ★ completedAtをnullにするためのロジックを追加
      completedAt: completedAtToNull ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isDone': isDone,
      'vehicleId': vehicleId,
      'workspaceId': workspaceId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'completedAt': completedAt, // ★ toMapに追加
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      isDone: map['isDone'] ?? false,
      vehicleId: map['vehicleId'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'],
      completedAt: map['completedAt'], // ★ fromMapに追加
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isDone,
    vehicleId,
    createdAt,
    createdBy,
    completedAt, // ★ Equatableのpropsに追加
  ];
}
