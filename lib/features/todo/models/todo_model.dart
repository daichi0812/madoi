// lib/features/todo/models/todo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final String id;
  final String content;
  final bool isDone;
  final int position;
  final String vehicleId;
  final String workspaceId;
  final Timestamp createdAt;
  final String? createdBy;
  final Timestamp? completedAt;
  final String? completedBy;

  const TodoModel({
    required this.id,
    required this.content,
    required this.isDone,
    required this.position,
    required this.vehicleId,
    required this.workspaceId,
    required this.createdAt,
    this.createdBy,
    this.completedAt,
    this.completedBy,
  });

  // copyWithメソッドを更新
  TodoModel copyWith({
    String? id,
    String? content,
    bool? isDone,
    int? position,
    String? vehicleId,
    String? workspaceId,
    Timestamp? createdAt,
    String? createdBy,
    String? completedBy,
    Timestamp? completedAt,
    bool completedAtToNull = false,
    bool completedByToNull = false,
  }) {
    return TodoModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      position: position ?? this.position,
      vehicleId: vehicleId ?? this.vehicleId,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      completedAt: completedAtToNull ? null : completedAt ?? this.completedAt,
      completedBy: completedByToNull ? null : completedBy ?? this.completedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isDone': isDone,
      'position': position,
      'vehicleId': vehicleId,
      'workspaceId': workspaceId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'completedAt': completedAt, // toMapに追加
      'completedBy': completedBy, // toMapに追加
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      isDone: map['isDone'] ?? false,
      position: map['position'] ?? 0,
      vehicleId: map['vehicleId'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'],
      completedAt: map['completedAt'], // fromMapに追加
      completedBy: map['completedBy'], // fromMapに追加
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    isDone,
    position,
    vehicleId,
    createdAt,
    createdBy,
    completedAt, // Equatableのpropsに追加
    completedBy, // Equatableのpropsに追加
  ];
}
