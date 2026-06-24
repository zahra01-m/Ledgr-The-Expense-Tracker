import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  food,
  transport,
  entertainment,
  shopping,
  health,
  utilities,
  other;

  String get displayName {
    switch (this) {
      case food:          return 'Food & Dining';
      case transport:     return 'Transport';
      case entertainment: return 'Entertainment';
      case shopping:      return 'Shopping';
      case health:        return 'Health';
      case utilities:     return 'Utilities';
      case other:         return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case food:          return '🍔';
      case transport:     return '🚗';
      case entertainment: return '🎬';
      case shopping:      return '🛍️';
      case health:        return '💊';
      case utilities:     return '💡';
      case other:         return '📦';
    }
  }
}

enum RecurrenceFrequency {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case none:    return 'None';
      case daily:   return 'Daily';
      case weekly:  return 'Weekly';
      case monthly: return 'Monthly';
      case yearly:  return 'Yearly';
    }
  }
}

/// Pure Dart entity — zero Flutter or Firebase imports.
/// This is the source of truth for what an "Expense" means in our app.
class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  
  // Recurring features
  final bool isRecurring;
  final RecurrenceFrequency frequency;

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
    this.isRecurring = false,
    this.frequency = RecurrenceFrequency.none,
  });

  ExpenseEntity copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    bool? isRecurring,
    RecurrenceFrequency? frequency,
  }) {
    return ExpenseEntity(
      id: id,
      userId: userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, title, amount, category, date, note, createdAt, isRecurring, frequency];
}
