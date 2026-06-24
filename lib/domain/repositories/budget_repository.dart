import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Stream<List<BudgetEntity>> getBudgets(String userId);
  Future<void> setBudget(BudgetEntity budget);
  Future<void> deleteBudget(String budgetId, String userId);
}
