import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository _repository;
  const GetExpensesUseCase(this._repository);

  Stream<List<ExpenseEntity>> call(String userId) =>
      _repository.getExpenses(userId);
}