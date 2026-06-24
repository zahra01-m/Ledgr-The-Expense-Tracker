import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository _repository;
  const UpdateExpenseUseCase(this._repository);

  Future<void> call(ExpenseEntity expense) =>
      _repository.updateExpense(expense);
}
