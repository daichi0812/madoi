// lib/features/record/repositories/record_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/record/models/record_model.dart';

class RecordRepository {
  final FirebaseFirestore _firestore;

  RecordRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // 車両と種類に紐づく記録一覧をStreamで取得
  Stream<List<RecordModel>> getRecordsStream({
    required String vehicleId,
    required RecordType type,
  }) {
    return _firestore
        .collection('records')
        .where('vehicleId', isEqualTo: vehicleId)
        .where('type', isEqualTo: type.name)
        .orderBy('recordDate', descending: true) // 新しい順に並べる
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecordModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
