// lib/features/workspace/repositories/workspace_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:madoi/features/workspace/models/workspace_model.dart';

class WorkspaceRepository {
  final FirebaseFirestore _firestore;

  WorkspaceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ワークスペースを作成するメソッド
  Future<void> createWorkspace(String name, String ownerId) async {
    // トランザクションを使い、複数の書き込み処理を安全に行う
    await _firestore.runTransaction((transaction) async {
      // 新しいワークスペースのドキュメント参照を作成 (IDは自動生成)
      final newWorkspaceRef = _firestore.collection('workspaces').doc();

      // 作成するワークスペースのモデルインスタンスを生成
      final newWorkspace = WorkspaceModel(
        id: newWorkspaceRef.id,
        name: name,
        ownerId: ownerId,
        members: [ownerId], // 作成者を最初のメンバーとして追加
        createdAt: Timestamp.now(),
      );

      // ユーザーのドキュメント参照を取得
      final userRef = _firestore.collection('users').doc(ownerId);

      // トランザクション内で書き込みを実行
      transaction.set(newWorkspaceRef, newWorkspace.toMap());
      transaction.update(userRef, {
        'memberOfWorkspaces': FieldValue.arrayUnion([newWorkspace.id]),
      });
    });
  }

  // ワークスペースIDを基にFirestoreからワークスペースドキュメントをStreamで取得
  Stream<WorkspaceModel?> getWorkspaceStream(String workspaceId) {
    return _firestore.collection('workspaces').doc(workspaceId).snapshots().map(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return WorkspaceModel.fromMap(snapshot.data()!);
        }
        return null;
      },
    );
  }

  // ワークスペースに参加するメソッド
  Future<void> joinWorkspace(String workspaceId, String userId) async {
    // 1. 処理開始のログ
    log('joinWorkspace処理開始: workspaceId="$workspaceId", userId="$userId"');

    final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);
    final userRef = _firestore.collection('users').doc(userId);

    try {
      // 1. まず、ワークスペースが存在するかどうかを単純に get する
      log('ワークスペースの存在確認を開始します...');
      final workspaceDoc = await workspaceRef.get();
      log('ワークスペースのドキュメント取得完了. 存在するか？ -> ${workspaceDoc.exists}');

      if (!workspaceDoc.exists) {
        log('ワークスペースが見つからないため、エラーを発生させます。');
        throw Exception('無効な招待コードです。ワークスペースが見つかりません。');
      }

      // 2. WriteBatch を使って、2つのドキュメントをアトミックに更新する
      log('WriteBatchを作成して、更新処理を開始します。');
      final batch = _firestore.batch();

      // ユーザーのドキュメントを更新
      batch.update(userRef, {
        'memberOfWorkspaces': FieldValue.arrayUnion([workspaceId]),
      });
      log('バッチにユーザー情報の更新を追加しました。');

      // ワークスペースのドキュメントを更新
      batch.update(workspaceRef, {
        'members': FieldValue.arrayUnion([userId]),
      });
      log('バッチにワークスペース情報の更新を追加しました。');

      // 3. バッチ処理をコミットする
      log('バッチをコミットします...');
      await batch.commit();
      log('バッチのコミットが完了しました。joinWorkspace処理が正常に終了しました。');
    } catch (e, s) {
      log('joinWorkspace処理中にエラーが発生しました: $e');
      log('スタックトレース: $s');
      // エラーを再度スローして、呼び出し元のControllerに伝える
      rethrow;
    }

    //   await _firestore.runTransaction((transaction) async {
    //     final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);
    //     final userRef = _firestore.collection('users').doc(userId);

    //     // 2. トランザクション開始とドキュメント取得のログ
    //     log('トランザクション内でワークスペースのドキュメントを取得します: path=${workspaceRef.path}');

    //     // ワークスペースが存在するか確認
    //     final workspaceDoc = await transaction.get(workspaceRef);
    //     if (!workspaceDoc.exists) {
    //       throw Exception('無効な招待コードです。');
    //     }

    //     // 3. ドキュメント取得結果のログ
    //     log('ワークスペースのドキュメント取得完了. ドキュメントは存在するか？ -> ${workspaceDoc.exists}');

    //     if (!workspaceDoc.exists) {
    //       // 4. ドキュメントが存在しない場合のログ
    //       log('ワークスペースのドキュメントが見つかりません。エラーを発生させます。');
    //       throw Exception('無効な招待コードです。ワークスペースが見つかりません。');
    //     }

    //     // 5. ドキュメント更新処理のログ
    //     log('ユーザーとワークスペースのドキュメントを更新します。');

    //     // ユーザーとワークスペースのドキュメントを更新
    //     transaction.update(userRef, {
    //       'memberOfWorkspaces': FieldValue.arrayUnion([workspaceId]),
    //     });
    //     transaction.update(workspaceRef, {
    //       'members': FieldValue.arrayUnion([userId]),
    //     });

    //     log('ドキュメント更新処理をトランザクションに追加しました。');
    //   });

    //   log('joinWorkspace処理が正常に終了しました。');
  }
}
