import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  const SignUpUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) =>
      _repository.signUp(email: email, password: password);
}