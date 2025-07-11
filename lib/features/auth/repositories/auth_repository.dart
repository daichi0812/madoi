// auth_repository.dart
// Firebase Authenticationとの実際の通信処理を担当するクラス
import "dart:developer";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:madoi/common/models/user_model.dart";

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             // Google Cloudコンソールで取得したWebクライアントIDを指定
             clientId:
                 '326840974680-nvkn5e9spdirs699rb72pk1u80d36qs0.apps.googleusercontent.com',
           ),
       _firestore = firestore ?? FirebaseFirestore.instance;

  // ログイン状態を監視するStream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Googleでサインイン
  Future<void> signInWithGoogle() async {
    try {
      // Googleサインインのポップアップを表示し、アカウントを選択させる
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Googleサインインがキャンセルされました");
      }

      // Googleアカウントの認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebaseが利用できる認証情報（Credential）を作成
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseにサインイン
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // 初回ログインかどうかの判定
      if (userCredential.user != null) {
        // usersコレクションにドキュメントが存在するかの確認
        var userDoc = await _firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .get();

        // ドキュメントが存在しない場合（=初回ログイン）のみ書き込み
        if (!userDoc.exists) {
          // 保存するユーザーモデルを作成
          var user = UserModel(
            uid: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? "名無しさん",
            email: userCredential.user!.email ?? "",
            profilePic: userCredential.user!.photoURL ?? "",
            memberOfWorkspaces: [],
          );

          // Firestoreの"users"コレクションにユーザー情報を保存
          await _firestore.collection("users").doc(user.uid).set(user.toMap());
        }
      }
    } catch (e) {
      // エラー処理
      log("Googleサインインエラー: ${e.toString()}");
      rethrow;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ユーザーIDをもとにFirestoreからユーザードキュメントをStreamで取得
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection("users").doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // 複数のユーザーIDのリストから、該当するユーザーのリストをStreamで取得する
  Stream<List<UserModel>> getUsersStream(List<String> uids) {
    // uidsのリストがからの場合は、からのリストを返すStreamを返す
    if (uids.isEmpty) {
      return Stream.value([]);
    }
    // Firestoreの 'whereIn' のクエリを使い、uidsリストに含まれるIDを持つユーザーを全て取得
    return _firestore
        .collection("users")
        .where('uid', whereIn: uids)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
