// lib/features/vehicle/models/vehicle_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String name; // 例: "ジムカーナDC2"
  final String nickname; // 例: "水野"
  final String workspaceId;
  final Timestamp createdAt;

  VehicleModel({
    required this.id,
    required this.name,
    required this.nickname,
    required this.workspaceId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'workspaceId': workspaceId,
      'createdAt': createdAt,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nickname: map['nickname'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
