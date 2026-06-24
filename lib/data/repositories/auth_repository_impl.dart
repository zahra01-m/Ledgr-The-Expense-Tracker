import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';

/// Bridges the domain contract to the Firebase service.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _service;
  const AuthRepositoryImpl(this._service);

  @override
  Future<UserEntity> signIn({required String email, required String password}) =>
      _service.signIn(email: email, password: password);

  @override
  Future<UserEntity> signUp({required String email, required String password}) =>
      _service.signUp(email: email, password: password);

  @override
  Future<UserEntity> signInWithGoogle() => _service.signInWithGoogle();

  @override
  Future<void> signOut() => _service.signOut();

  @override
  Stream<UserEntity?> get authStateChanges => _service.authStateChanges;
}