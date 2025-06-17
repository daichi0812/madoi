// auth_repository.dart
// Firebase Authenticationとの実際の通信処理を担当するクラス
import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ログイン状態を監視するStream
  Stream<User?> get authStateChange => _auth.authStateChanges();

  // Googleでサインイン
  Future<UserCredential> signInWithGoogle() async {
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
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // エラー処理
      print("Googleサインインエラー: ${e.toString()}");
      rethrow;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
