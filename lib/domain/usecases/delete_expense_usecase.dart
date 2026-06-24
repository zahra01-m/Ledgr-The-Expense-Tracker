import '../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository _repository;
  const DeleteExpenseUseCase(this._repository);

  Future<void> call({
    required String expenseId,
    required String userId,
  }) =>
      _repository.deleteExpense(expenseId: expenseId, userId: userId);
}