// lib/common/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final List<String> memberOfWorkspaces;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.memberOfWorkspaces,
  });

  // DartのオブジェクトをFirestoreがわかるMap形式に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'memberOfWorkspaces': memberOfWorkspaces,
    };
  }

  // FirestoreのMap形式のデータからDartのオブジェクトを生成するファクトリコンストラクタ
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      memberOfWorkspaces: List<String>.from(map['memberOfWorkspaces'] ?? []),
    );
  }
}
