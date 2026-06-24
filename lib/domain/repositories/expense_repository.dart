import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  /// Real-time stream — UI updates automatically when Firestore changes.
  Stream<List<ExpenseEntity>> getExpenses(String userId);

  Future<void> addExpense(ExpenseEntity expense);

  Future<void> updateExpense(ExpenseEntity expense);

  Future<void> deleteExpense({
    required String expenseId,
    required String userId,
  });
}