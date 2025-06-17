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
    required String workspaceId,
  }) {
    return _firestore
        .collection('records')
        .where('workspaceId', isEqualTo: workspaceId)
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

  // 新しい記録を追加するメソッドを追加
  Future<void> addRecord({
    required String content,
    required RecordType type,
    required String vehicleId,
    required String workspaceId,
  }) async {
    final newRecordRef = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('records')
        .doc();

    final newRecord = RecordModel(
      id: newRecordRef.id,
      content: content,
      type: type,
      recordDate: Timestamp.now(),
      vehicleId: vehicleId,
      workspaceId: workspaceId,
    );
    await newRecordRef.set(newRecord.toMap());
  }
}
