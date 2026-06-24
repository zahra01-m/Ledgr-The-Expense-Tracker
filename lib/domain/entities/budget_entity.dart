import 'package:equatable/equatable.dart';
import 'expense_entity.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final ExpenseCategory category;
  final double limit;
  final double spent;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    this.spent = 0.0,
  });

  double get percentage => spent / limit;
  bool get isOverBudget => spent > limit;

  BudgetEntity copyWith({
    double? limit,
    double? spent,
  }) {
    return BudgetEntity(
      id: id,
      userId: userId,
      category: category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }

  @override
  List<Object?> get props => [id, userId, category, limit, spent];
}
