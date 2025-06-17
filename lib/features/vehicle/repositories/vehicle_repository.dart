// lib/features/vehicle/repositories/vehicle_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/vehicle/models/vehicle_model.dart';

class VehicleRepository {
  final FirebaseFirestore _firestore;

  VehicleRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // workspaceIdを親ドキュメントのパスとして使用
  Stream<List<VehicleModel>> getVehiclesStream(String workspaceId) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection("vehicles")
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
    final newVehicleRef = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection("vehicles")
        .doc();
    final newVehicle = VehicleModel(
      id: newVehicleRef.id,
      name: name,
      nickname: nickname,
      workspaceId: workspaceId,
      createdAt: Timestamp.now(),
    );
    await newVehicleRef.set(newVehicle.toMap());
  }

  // 車両IDをもとに単一の車両データをStreamで取得
  Stream<VehicleModel?> getVehicleStream(String workspaceId, String vehicleId) {
    return _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return VehicleModel.fromMap(snapshot.data()!);
          }
          return null;
        });
  }
}
