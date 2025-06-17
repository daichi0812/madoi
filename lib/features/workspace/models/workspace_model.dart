// lib/features/workspace/models/workspace_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final Timestamp createdAt;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'members': members,
      'createdAt': createdAt,
    };
  }

  factory WorkspaceModel.fromMap(Map<String, dynamic> map) {
    return WorkspaceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
