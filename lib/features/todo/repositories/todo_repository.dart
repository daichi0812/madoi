// lib/features/todo/repositories/todo_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/todo/models/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore;

  TodoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // 基準となるコレクションへの参照を返すヘルパー
  CollectionReference _todosRef(String workspaceId, String vehicleId) {
    return _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('todos');
  }

  // サブコレクションのパスを指定
  Stream<List<TodoModel>> getTodosStream({
    required String workspaceId,
    required String vehicleId,
  }) {
    return _todosRef(workspaceId, vehicleId)
        .orderBy('position')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TodoModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // 単一のToDoデータをStreamで取得するメソッドを追加
  Stream<TodoModel?> getTodoStream({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
  }) {
    return _todosRef(workspaceId, vehicleId).doc(todoId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return TodoModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // 新しいToDoを追加
  Future<void> addTodo({
    required String content,
    required String vehicleId,
    required String workspaceId,
  }) async {
    final todosCollection = _todosRef(workspaceId, vehicleId);
    final newTodoRef = todosCollection.doc();

    // トランザクションを使い、現在のToDo数を安全に取得してpositionを設定
    await _firestore.runTransaction((transaction) async {
      // isDoneがfalseのToDoの数を取得
      final querySnapshot = await todosCollection
          .where('isDone', isEqualTo: false)
          .get();

      // 既存の未完了ToDoのpositionを+1する
      for (final doc in querySnapshot.docs) {
        final currentPosition = doc.get('position') as int;
        transaction.update(doc.reference, {'position': currentPosition + 1});
      }

      // 新しいToDoをposition: 0で作成
      final newTodo = TodoModel(
        id: newTodoRef.id,
        content: content,
        isDone: false,
        position: 0,
        createdAt: Timestamp.now(),
        vehicleId: vehicleId,
        workspaceId: workspaceId,
      );
      transaction.set(newTodoRef, newTodo.toMap());
    });
  }

  // ToDoを並び替えるメソッド
  Future<void> reorderTodos({
    required String workspaceId,
    required String vehicleId,
    required List<TodoModel> todos,
  }) async {
    final batch = _firestore.batch();
    final todosCollection = _todosRef(workspaceId, vehicleId);

    for (int i = 0; i < todos.length; ++i) {
      final todo = todos[i];
      if (todo.position != i) {
        final docRef = todosCollection.doc(todo.id);
        batch.update(docRef, {'position': i});
      }
    }
    await batch.commit();
  }

  // ToDoの内容を更新するメソッドを追加
  Future<void> updateTodo({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
    required String content,
  }) async {
    await _todosRef(
      workspaceId,
      vehicleId,
    ).doc(todoId).update({'content': content});
  }

  // ToDoの完了状態を切り替える
  Future<void> toggleTodoStatus({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
    required bool isDone,
    required String userId,
  }) async {
    final todosCollection = _todosRef(workspaceId, vehicleId);
    final todoRef = _todosRef(workspaceId, vehicleId).doc(todoId);

    // 完了状態に応じてcompletedAtとpositionを更新
    if (isDone) {
      // 完了にする場合（リストから見えなくなり、完了済みリストへ）
      await todoRef.update({
        'isDone': isDone,
        'completedAt': isDone ? Timestamp.now() : null,
        'completedBy': userId,
        'position': -1,
      });
    } else {
      // 未完了に戻す場合（一番上に追加）
      await _firestore.runTransaction((transaction) async {
        // 既存の未完了ToDoを取得
        final querySnapshot = await todosCollection
            .where('isDone', isEqualTo: false)
            .get();

        // 既存の未完了ToDoのpositionを+1する
        for (final doc in querySnapshot.docs) {
          final currentPosition = doc.get('position') as int;
          transaction.update(doc.reference, {'position': currentPosition + 1});
        }

        // 対象のToDoを未完了に戻し、position: 0に設定
        transaction.update(todoRef, {
          'isDone': false,
          'completedAt': null,
          'completedBy': null,
          'position': 0,
        });
      });
    }
  }

  // ToDoを削除するメソッド
  Future<void> deleteTodo({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
  }) async {
    await _todosRef(workspaceId, vehicleId).doc(todoId).delete();
  }
}
