import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/expense_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.limit,
    super.spent,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] as String,
      category: ExpenseCategory.values.firstWhere(
            (e) => e.name == data['category'],
        orElse: () => ExpenseCategory.other,
      ),
      limit: (data['limit'] as num).toDouble(),
      spent: (data['spent'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'category': category.name,
    'limit': limit,
    'spent': spent,
  };

  factory BudgetModel.fromEntity(BudgetEntity entity) => BudgetModel(
    id: entity.id,
    userId: entity.userId,
    category: entity.category,
    limit: entity.limit,
    spent: entity.spent,
  );
}
