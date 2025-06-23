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
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .collection('records')
        .where('type', isEqualTo: type.name)
        .orderBy('recordDate', descending: true) // 新しい順に並べる
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecordModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ★ 単一の記録データをStreamで取得するメソッドを追加
  Stream<RecordModel?> getRecordStream({
    required String workspaceId,
    required String vehicleId,
    required String recordId,
  }) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('records')
        .doc(recordId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return RecordModel.fromMap(snapshot.data()!);
          }
          return null;
        });
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

  // 既存の記録を更新するメソッドを追加
  Future<void> updateRecord({
    required String content,
    required String workspaceId,
    required String vehicleId,
    required String recordId,
  }) async {
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('records')
        .doc(recordId)
        .update({'content': content});
  }

  // 記録を削除するメソッド
  Future<void> deleteRecord({
    required String workspaceId,
    required String vehicleId,
    required String recordId,
  }) async {
    await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('records')
        .doc(recordId)
        .delete();
  }
}
