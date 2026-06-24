import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/providers.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseController extends AsyncNotifier<List<ExpenseEntity>> {
  StreamSubscription<List<ExpenseEntity>>? _sub;

  @override
  Future<List<ExpenseEntity>> build() async {
    final user = ref.watch(authStateProvider).value;
    final userId = user?.uid;
    if (userId == null) {
      debugPrint('ExpenseController: No userId found.');
      return [];
    }
    debugPrint('ExpenseController: Building for userId: $userId (Email: ${user?.email})');

    // Cancel any existing stream before subscribing to a new one.
    _sub?.cancel();
    ref.onDispose(() => _sub?.cancel());

    final useCase = ref.read(getExpensesUseCaseProvider);
    final completer = Completer<List<ExpenseEntity>>();

    _sub = useCase(userId).listen(
          (expenses) {
        if (!completer.isCompleted) {
          completer.complete(expenses);
        } else {
          // Stream already started — update state reactively.
          state = AsyncData(expenses);
        }
      },
      onError: (Object e) {
        final failure = e is Failure ? e : UnknownFailure(e.toString());
        if (!completer.isCompleted) {
          completer.completeError(failure);
        } else {
          state = AsyncError(failure, StackTrace.current);
        }
      },
    );

    return completer.future;
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
    bool isRecurring = false,
    RecurrenceFrequency frequency = RecurrenceFrequency.none,
  }) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) throw const AuthFailure('Not authenticated.');
    debugPrint('ExpenseController: Adding expense for userId: $userId');

    final expense = ExpenseEntity(
      id: const Uuid().v4(),
      userId: userId,
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      createdAt: DateTime.now(),
      isRecurring: isRecurring,
      frequency: frequency,
    );

    await ref.read(addExpenseUseCaseProvider)(expense);
  }

  Future<void> updateExpense(ExpenseEntity expense) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) throw const AuthFailure('Not authenticated.');
    debugPrint('ExpenseController: Updating expense for userId: $userId');

    await ref.read(updateExpenseUseCaseProvider)(expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) throw const AuthFailure('Not authenticated.');
    debugPrint('ExpenseController: Deleting expense for userId: $userId');

    await ref
        .read(deleteExpenseUseCaseProvider)
        .call(expenseId: expenseId, userId: userId);
  }

  // ─── Computed Getters ──────────────────────────────────────────

  double get totalExpenses =>
      state.value?.fold(0.0, (sum, e) => sum! + e.amount) ?? 0.0;

  Map<ExpenseCategory, double> get expensesByCategory {
    final expenses = state.value ?? [];
    return expenses.fold({}, (map, e) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
      return map;
    });
  }
}

final expenseControllerProvider =
AsyncNotifierProvider<ExpenseController, List<ExpenseEntity>>(
  ExpenseController.new,
);

// ─── Filtering & Search Providers ────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final categoryFilterProvider = StateProvider<ExpenseCategory?>((ref) => null);

enum ExpenseSortOption {
  dateNewest,
  dateOldest,
  amountHighToLow,
  amountLowToHigh,
  titleAZ;

  String get displayName {
    switch (this) {
      case ExpenseSortOption.dateNewest:       return 'Date: Newest first';
      case ExpenseSortOption.dateOldest:       return 'Date: Oldest first';
      case ExpenseSortOption.amountHighToLow:  return 'Amount: High to low';
      case ExpenseSortOption.amountLowToHigh:  return 'Amount: Low to high';
      case ExpenseSortOption.titleAZ:          return 'Title: A to Z';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseSortOption.dateNewest:       return '🕓';
      case ExpenseSortOption.dateOldest:       return '🕛';
      case ExpenseSortOption.amountHighToLow:  return '⬇️';
      case ExpenseSortOption.amountLowToHigh:  return '⬆️';
      case ExpenseSortOption.titleAZ:          return '🔤';
    }
  }
}

final sortOptionProvider =
StateProvider<ExpenseSortOption>((ref) => ExpenseSortOption.dateNewest);

final filteredExpensesProvider = Provider<AsyncValue<List<ExpenseEntity>>>((ref) {
  final expensesAsync = ref.watch(expenseControllerProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(categoryFilterProvider);
  final sortOption = ref.watch(sortOptionProvider);

  return expensesAsync.whenData((expenses) {
    final filtered = expenses.where((e) {
      final matchesQuery =
          e.title.toLowerCase().contains(query) || (e.note?.toLowerCase().contains(query) ?? false);
      final matchesCategory =
          selectedCategory == null || e.category == selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      switch (sortOption) {
        case ExpenseSortOption.dateNewest:
          return b.date.compareTo(a.date);
        case ExpenseSortOption.dateOldest:
          return a.date.compareTo(b.date);
        case ExpenseSortOption.amountHighToLow:
          return b.amount.compareTo(a.amount);
        case ExpenseSortOption.amountLowToHigh:
          return a.amount.compareTo(b.amount);
        case ExpenseSortOption.titleAZ:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return filtered;
  });
});