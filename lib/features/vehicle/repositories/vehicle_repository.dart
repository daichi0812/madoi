// lib/features/vehicle/repositories/vehicle_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/vehicle/models/vehicle_model.dart';

class VehicleRepository {
  final FirebaseFirestore _firestore;

  VehicleRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ワークスペースIDに紐づく車両一覧をStreamで取得
  Stream<List<VehicleModel>> getVehiclesStream(String workspaceId) {
    return _firestore
        .collection('vehicles')
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => VehicleModel.fromMap(doc.data()))
              .toList();
        });
  }

  // 新しい車両を追加
  Future<void> addVehicle({
    required String name,
    required String nickname,
    required String workspaceId,
  }) async {
    final newVehicleRef = _firestore.collection('vehicles').doc();
    final newVehicle = VehicleModel(
      id: newVehicleRef.id,
      name: name,
      nickname: nickname,
      workspaceId: workspaceId,
      createdAt: Timestamp.now(),
    );
    await newVehicleRef.set(newVehicle.toMap());
  }
}
