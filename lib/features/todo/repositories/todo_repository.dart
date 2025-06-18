// lib/features/todo/repositories/todo_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/todo/models/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore;

  TodoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // サブコレクションのパスを指定
  Stream<List<TodoModel>> getTodosStream({
    required String workspaceId,
    required String vehicleId,
  }) {
    return _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .collection('todos')
        .orderBy('createdAt', descending: true) // 作成順と逆に並べる
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TodoModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // 単一のToDoデータをStreamで取得するメソッドを追加
  Stream<TodoModel?> getTodoStream({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
  }) {
    return _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .collection("todos")
        .doc(todoId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return TodoModel.fromMap(snapshot.data()!);
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
    final newTodoRef = _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .collection('todos')
        .doc();
    final newTodo = TodoModel(
      id: newTodoRef.id,
      content: content,
      isDone: false,
      createdAt: Timestamp.now(),
      vehicleId: vehicleId,
      workspaceId: workspaceId,
    );
    await newTodoRef.set(newTodo.toMap());
  }

  // ToDoの内容を更新するメソッドを追加
  Future<void> updateTodo({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
    required String content,
  }) async {
    await _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('todos')
        .doc(todoId)
        .update({'content': content});
  }

  // ToDoの完了状態を切り替える
  Future<void> toggleTodoStatus({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
    required bool isDone,
  }) async {
    final todoRef = _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .collection('todos')
        .doc(todoId);

    // 完了状態に応じてcompletedAtを更新
    await todoRef.update({
      'isDone': isDone,
      'completedAt': isDone ? Timestamp.now() : null,
    });
  }

  // ToDoを削除するメソッド
  Future<void> deleteTodo({
    required String workspaceId,
    required String vehicleId,
    required String todoId,
  }) async {
    await _firestore
        .collection("workspaces")
        .doc(workspaceId)
        .collection("vehicles")
        .doc(vehicleId)
        .collection("todos")
        .doc(todoId)
        .delete();
  }
}
