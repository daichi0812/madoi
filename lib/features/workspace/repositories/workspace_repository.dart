// lib/features/workspace/repositories/workspace_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/workspace/models/workspace_model.dart';

class WorkspaceRepository {
  final FirebaseFirestore _firestore;

  WorkspaceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ワークスペースを作成するメソッド
  Future<void> createWorkspace(String name, String ownerId) async {
    // トランザクションを使い、複数の書き込み処理を安全に行う
    await _firestore.runTransaction((transaction) async {
      // 1. 新しいワークスペースのドキュメント参照を作成 (IDは自動生成)
      final newWorkspaceRef = _firestore.collection('workspaces').doc();

      // 2. 作成するワークスペースのモデルインスタンスを生成
      final newWorkspace = WorkspaceModel(
        id: newWorkspaceRef.id,
        name: name,
        ownerId: ownerId,
        members: [ownerId], // 作成者を最初のメンバーとして追加
        createdAt: Timestamp.now(),
      );

      // 3. ユーザーのドキュメント参照を取得
      final userRef = _firestore.collection('users').doc(ownerId);

      // 4. トランザクション内で書き込みを実行
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
    // 参加したいワークスペースのドキュメントが存在するか、まず確認する
    final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);
    final workspaceDoc = await workspaceRef.get();
    if (!workspaceDoc.exists) {
      throw Exception('無効な招待コードです。');
    }

    // 自分のユーザードキュメントに、ワークスペースIDを追加する
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'memberOfWorkspaces': FieldValue.arrayUnion([workspaceId]),
    });

    // ワークスペースのドキュメントに、自分のIDを追加する
    await workspaceRef.update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }
}
