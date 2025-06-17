// auth_providers.dart
/* AuthRepositoryやログイン状態を、アプリの他の場所から安全に利用するための
   Riverpod Providerを定義 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/auth/repositories/auth_repository.dart'; // 作成したRepositoryをインポート

// AuthRepositoryのインスタンスをシングルトンで提供するProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ログイン状態(Userオブジェクト)をリアルタイムで監視し、アプリ全体に提供するProvider
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// ログイン処理を実行するためのProvider
// StateNotifierProviderは、状態（例：ローディング中）を持つ場合に便利ですが、
// 今回はシンプルにFutureを返すProviderでログイン処理を呼び出します。
final loginProvider = Provider((ref) {
  return ref.read(authRepositoryProvider);
});
