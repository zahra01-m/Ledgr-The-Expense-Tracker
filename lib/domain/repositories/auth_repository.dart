import '../entities/user_entity.dart';

/// Abstract contract — the data layer must implement this.
/// The domain layer never knows about Firebase directly.
abstract class AuthRepository {
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  Future<UserEntity> signUp({
    required String email,
    required String password,
  });

  Future<UserEntity> signInWithGoogle();

  Future<void> signOut();

  /// Emits the current user whenever auth state changes (login/logout).
  Stream<UserEntity?> get authStateChanges;
}