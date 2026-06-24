import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository _repository;
  const AddExpenseUseCase(this._repository);

  Future<void> call(ExpenseEntity expense) =>
      _repository.addExpense(expense);
}