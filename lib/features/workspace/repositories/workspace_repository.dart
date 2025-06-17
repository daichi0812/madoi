// lib/features/workspace/repositories/workspace_repository.dart
import 'dart:developer'; // logを使うためにインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/workspace/models/workspace_model.dart';

class WorkspaceRepository {
  final FirebaseFirestore _firestore;

  WorkspaceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ワークスペースを作成するメソッド
  Future<void> createWorkspace(String name, String ownerId) async {
    // ★★★ デバッグのため、一時的にトランザクションを使わない形に変更 ★★★
    try {
      // 1. 新しいワークスペースのドキュメント参照を作成
      final newWorkspaceRef = _firestore.collection('workspaces').doc();
      final newWorkspace = WorkspaceModel(
        id: newWorkspaceRef.id,
        name: name,
        ownerId: ownerId,
        members: [ownerId],
        createdAt: Timestamp.now(),
      );
      // 新しいワークスペースをセット
      await newWorkspaceRef.set(newWorkspace.toMap());
      log('ワークスペースの作成に成功しました。');

      // 2. ユーザーのドキュメントを更新
      final userRef = _firestore.collection('users').doc(ownerId);
      await userRef.update({
        'memberOfWorkspaces': FieldValue.arrayUnion([newWorkspace.id]),
      });
      log('ユーザー情報の更新に成功しました。');
    } catch (e) {
      log('デバッグ中のエラー: $e');
      rethrow; // エラーを再スローしてコントローラーに伝える
    }
  }
}
