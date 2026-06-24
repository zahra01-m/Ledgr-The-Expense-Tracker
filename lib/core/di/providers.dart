import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';

// ─── Firebase Instances ───────────────────────────────────────────
final firebaseAuthInstanceProvider =
Provider<FirebaseAuth>((_) => FirebaseAuth.instance);

final googleSignInInstanceProvider = Provider<GoogleSignIn>((_) {
  return GoogleSignIn(
    // Note: For Web, you must provide a clientId.
    // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  );
});

final firestoreInstanceProvider =
Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

// ─── Services ────────────────────────────────────────────────────
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
      (ref) => FirebaseAuthService(
    ref.read(firebaseAuthInstanceProvider),
    ref.read(googleSignInInstanceProvider),
  ),
);

final firestoreServiceProvider = Provider<FirestoreService>(
      (ref) => FirestoreService(ref.read(firestoreInstanceProvider)),
);

// ─── Repositories ────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepositoryImpl(ref.read(firebaseAuthServiceProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
      (ref) => ExpenseRepositoryImpl(ref.read(firestoreServiceProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
      (ref) => BudgetRepositoryImpl(ref.read(firestoreServiceProvider)),
);

// ─── Use Cases ───────────────────────────────────────────────────
final signInUseCaseProvider = Provider<SignInUseCase>(
        (ref) => SignInUseCase(ref.read(authRepositoryProvider)));

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>(
        (ref) => SignInWithGoogleUseCase(ref.read(authRepositoryProvider)));

final signUpUseCaseProvider = Provider<SignUpUseCase>(
        (ref) => SignUpUseCase(ref.read(authRepositoryProvider)));

final signOutUseCaseProvider = Provider<SignOutUseCase>(
        (ref) => SignOutUseCase(ref.read(authRepositoryProvider)));

final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>(
        (ref) => AddExpenseUseCase(ref.read(expenseRepositoryProvider)));

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>(
        (ref) => DeleteExpenseUseCase(ref.read(expenseRepositoryProvider)));

final updateExpenseUseCaseProvider = Provider<UpdateExpenseUseCase>(
        (ref) => UpdateExpenseUseCase(ref.read(expenseRepositoryProvider)));

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>(
        (ref) => GetExpensesUseCase(ref.read(expenseRepositoryProvider)));

// ─── Global Auth Stream ──────────────────────────────────────────
/// Single source of truth for the current user across the app.
final authStateProvider = StreamProvider<UserEntity?>(
      (ref) => ref.read(authRepositoryProvider).authStateChanges,
);