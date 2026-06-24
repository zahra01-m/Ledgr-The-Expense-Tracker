class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Tracker';

  // Firestore structure: users/{userId}/expenses/{expenseId}
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String budgetsCollection = 'budgets';
}
