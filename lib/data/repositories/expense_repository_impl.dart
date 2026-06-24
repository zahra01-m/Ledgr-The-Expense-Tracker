import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirestoreService _service;
  const ExpenseRepositoryImpl(this._service);

  @override
  Stream<List<ExpenseEntity>> getExpenses(String userId) =>
      _service.getExpenses(userId);

  @override
  Future<void> addExpense(ExpenseEntity expense) =>
      _service.addExpense(ExpenseModel.fromEntity(expense));

  @override
  Future<void> updateExpense(ExpenseEntity expense) =>
      _service.updateExpense(ExpenseModel.fromEntity(expense));

  @override
  Future<void> deleteExpense({
    required String expenseId,
    required String userId,
  }) =>
      _service.deleteExpense(expenseId: expenseId, userId: userId);
}