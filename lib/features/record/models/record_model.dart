// lib/features/record/models/record_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordType { maintenance, setting }

class RecordModel {
  final String id;
  final String content; // Markdown形式の本文
  final RecordType type; // 記録の種類（整備 or セッティング）
  final Timestamp recordDate; // 記録日
  final String vehicleId;
  final String workspaceId;

  RecordModel({
    required this.id,
    required this.content,
    required this.type,
    required this.recordDate,
    required this.vehicleId,
    required this.workspaceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name, // Enumを文字列として保存
      'recordDate': recordDate,
      'vehicleId': vehicleId,
      'workspaceId': workspaceId,
    };
  }

  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      // 文字列からEnumに変換
      type: RecordType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RecordType.maintenance,
      ),
      recordDate: map['recordDate'] ?? Timestamp.now(),
      vehicleId: map['vehicleId'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
    );
  }
}
