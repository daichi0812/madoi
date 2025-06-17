// lib/common/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePic;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
  });

  // DartのオブジェクトをFirestoreがわかるMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'email': email, 'profilePic': profilePic};
  }

  // FirestoreのMap形式のデータからDartのオブジェクトを生成するファクトリコンストラクタ
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }
}
