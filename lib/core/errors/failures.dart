/// Base class for all domain-level failures.
/// Using a class hierarchy lets controllers catch specific failure types.
abstract class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
