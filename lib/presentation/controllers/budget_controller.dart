import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/expense_entity.dart';
import 'expense_controller.dart';

class BudgetController extends AsyncNotifier<List<BudgetEntity>> {
  @override
  Future<List<BudgetEntity>> build() async {
    final userId = ref.watch(authStateProvider).value?.uid;
    if (userId == null) return [];

    final repository = ref.read(budgetRepositoryProvider);
    final expensesAsync = ref.watch(expenseControllerProvider);

    final completer = Completer<List<BudgetEntity>>();
    
    final sub = repository.getBudgets(userId).listen((budgets) {
      final expenses = expensesAsync.value ?? [];
      
      final updatedBudgets = budgets.map((budget) {
        final spent = expenses
            .where((e) => e.category == budget.category)
            .fold(0.0, (sum, e) => sum + e.amount);
        return budget.copyWith(spent: spent);
      }).toList();

      if (!completer.isCompleted) {
        completer.complete(updatedBudgets);
      } else {
        state = AsyncData(updatedBudgets);
      }
    });

    ref.onDispose(() => sub.cancel());
    return completer.future;
  }

  Future<void> setBudget(ExpenseCategory category, double limit) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    final existing = state.value?.where((b) => b.category == category).firstOrNull;
    
    final budget = BudgetEntity(
      id: existing?.id ?? const Uuid().v4(),
      userId: userId,
      category: category,
      limit: limit,
    );

    await ref.read(budgetRepositoryProvider).setBudget(budget);
  }

  Future<void> deleteBudget(String budgetId) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;
    await ref.read(budgetRepositoryProvider).deleteBudget(budgetId, userId);
  }
}

final budgetControllerProvider =
    AsyncNotifierProvider<BudgetController, List<BudgetEntity>>(BudgetController.new);
