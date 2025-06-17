// lib/features/todo/repositories/todo_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madoi/features/todo/models/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore;

  TodoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // 車両IDに紐づくToDo一覧をStreamで取得
  Stream<List<TodoModel>> getTodosStream(String vehicleId) {
    return _firestore
        .collection('todos')
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('createdAt', descending: false) // 作成順に並べる
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TodoModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // 新しいToDoを追加
  Future<void> addTodo({
    required String content,
    required String vehicleId,
    required String workspaceId,
  }) async {
    final newTodoRef = _firestore.collection('todos').doc();
    final newTodo = TodoModel(
      id: newTodoRef.id,
      content: content,
      isCompleted: false,
      createdAt: Timestamp.now(),
      vehicleId: vehicleId,
      workspaceId: workspaceId,
    );
    await newTodoRef.set(newTodo.toMap());
  }

  // ToDoの完了状態を切り替える
  Future<void> toggleTodoStatus({
    required String todoId,
    required bool currentStatus,
  }) async {
    await _firestore.collection('todos').doc(todoId).update({
      'isCompleted': !currentStatus,
    });
  }
}
