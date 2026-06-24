import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

/// Extends ExpenseEntity with Firestore serialization.
/// The domain layer stays clean — only this model knows about Firestore types.
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
    super.note,
    required super.createdAt,
    super.isRecurring,
    super.frequency,
  });

  factory ExpenseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
            (e) => e.name == data['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      frequency: RecurrenceFrequency.values.firstWhere(
            (e) => e.name == (data['frequency'] as String? ?? 'none'),
        orElse: () => RecurrenceFrequency.none,
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'amount': amount,
    'category': category.name,
    'date': Timestamp.fromDate(date),
    'note': note,
    'createdAt': Timestamp.fromDate(createdAt),
    'isRecurring': isRecurring,
    'frequency': frequency.name,
  };

  factory ExpenseModel.fromEntity(ExpenseEntity entity) => ExpenseModel(
    id: entity.id,
    userId: entity.userId,
    title: entity.title,
    amount: entity.amount,
    category: entity.category,
    date: entity.date,
    note: entity.note,
    createdAt: entity.createdAt,
    isRecurring: entity.isRecurring,
    frequency: entity.frequency,
  );
}
