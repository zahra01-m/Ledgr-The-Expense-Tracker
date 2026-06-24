import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';
import '../services/firestore_service.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final FirestoreService _service;
  const BudgetRepositoryImpl(this._service);

  @override
  Stream<List<BudgetEntity>> getBudgets(String userId) =>
      _service.getBudgets(userId);

  @override
  Future<void> setBudget(BudgetEntity budget) =>
      _service.setBudget(BudgetModel.fromEntity(budget));

  @override
  Future<void> deleteBudget(String budgetId, String userId) =>
      _service.deleteBudget(budgetId, userId);
}
