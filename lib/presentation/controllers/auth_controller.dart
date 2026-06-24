import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    // Derive initial state from the global auth stream.
    // When the stream emits, Riverpod will rebuild this notifier.
    final authStream = ref.watch(authStateProvider);
    return authStream.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref.read(signInUseCaseProvider)(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithGoogleUseCaseProvider)(),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref.read(signUpUseCaseProvider)(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(signOutUseCaseProvider)();
      return null;
    });
  }

  /// Extracts a human-readable error message from the state.
  String? get errorMessage => state.whenOrNull(
    error: (e, _) => e is Failure ? e.message : 'An error occurred.',
  );

  Failure? get error => state.whenOrNull(
    error: (e, _) => e is Failure ? e : UnknownFailure(e.toString()),
  );
}

final authControllerProvider =
AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);