import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  const FirestoreService(this._firestore);

  /// Path: users/{userId}/expenses
  CollectionReference<Map<String, dynamic>> _expensesRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.expensesCollection);
  }

  CollectionReference<Map<String, dynamic>> _budgetsRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.budgetsCollection);
  }

  /// Verifies if the app can reach the Firestore server.
  Future<void> testConnection() async {
    try {
      debugPrint('Firestore: Checking connectivity...');
      // Just a lightweight read to check if we can reach the server
      await _firestore.collection('health_check').doc('ping').get(
        const GetOptions(source: Source.server),
      );
      debugPrint('Firestore: Connectivity SUCCESS');
    } catch (e) {
      debugPrint('Firestore: Connectivity ERROR: $e');
      rethrow;
    }
  }

  Stream<List<ExpenseModel>> getExpenses(String userId) {
    debugPrint('Firestore: Listening for expenses for userId: $userId');
    return _expensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
          debugPrint('Firestore: Received ${snap.docs.length} expenses for user $userId');
          return snap.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
        })
        .handleError((Object e) {
          debugPrint('Firestore: Stream Error (Expenses): $e');
          throw DatabaseFailure('Failed to fetch expenses: $e');
        });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      debugPrint('Firestore: Adding expense ${expense.id}...');
      await _expensesRef(expense.userId)
          .doc(expense.id)
          .set(expense.toFirestore());
      debugPrint('Firestore: Expense added successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firestore: Firebase Error (Add): ${e.code} - ${e.message}');
      throw DatabaseFailure(e.message ?? 'Failed to add expense.', code: e.code);
    } catch (e) {
      debugPrint('Firestore: Unknown Error (Add): $e');
      throw const UnknownFailure('An unexpected error occurred while adding expense.');
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      debugPrint('Firestore: Updating expense ${expense.id}...');
      await _expensesRef(expense.userId)
          .doc(expense.id)
          .update(expense.toFirestore());
      debugPrint('Firestore: Expense updated successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firestore: Firebase Error (Update): ${e.code} - ${e.message}');
      throw DatabaseFailure(e.message ?? 'Failed to update expense.', code: e.code);
    } catch (e) {
      debugPrint('Firestore: Unknown Error (Update): $e');
      throw const UnknownFailure('An unexpected error occurred while updating expense.');
    }
  }

  Future<void> deleteExpense({
    required String expenseId,
    required String userId,
  }) async {
    try {
      debugPrint('Firestore: Deleting expense $expenseId...');
      await _expensesRef(userId).doc(expenseId).delete();
      debugPrint('Firestore: Expense deleted successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firestore: Firebase Error (Delete): ${e.code} - ${e.message}');
      throw DatabaseFailure(e.message ?? 'Failed to delete expense.', code: e.code);
    } catch (e) {
      debugPrint('Firestore: Unknown Error (Delete): $e');
      throw const UnknownFailure('An unexpected error occurred while deleting expense.');
    }
  }

  // ─── Budgets ───────────────────────────────────────────────────

  Stream<List<BudgetModel>> getBudgets(String userId) {
    return _budgetsRef(userId).snapshots().map((snap) {
      debugPrint('Firestore: Received ${snap.docs.length} budgets');
      return snap.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList();
    }).handleError((Object e) {
      debugPrint('Firestore: Stream Error (Budgets): $e');
      throw DatabaseFailure('Failed to fetch budgets: $e');
    });
  }

  Future<void> setBudget(BudgetModel budget) async {
    try {
      debugPrint('Firestore: Setting budget for ${budget.category.name}...');
      await _budgetsRef(budget.userId).doc(budget.id).set(budget.toFirestore());
      debugPrint('Firestore: Budget set successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firestore: Firebase Error (SetBudget): ${e.code} - ${e.message}');
      throw DatabaseFailure(e.message ?? 'Failed to set budget.', code: e.code);
    } catch (e) {
      debugPrint('Firestore: Unknown Error (SetBudget): $e');
      throw const UnknownFailure('An unexpected error occurred while setting budget.');
    }
  }

  Future<void> deleteBudget(String budgetId, String userId) async {
    try {
      debugPrint('Firestore: Deleting budget $budgetId...');
      await _budgetsRef(userId).doc(budgetId).delete();
      debugPrint('Firestore: Budget deleted successfully');
    } on FirebaseException catch (e) {
      debugPrint('Firestore: Firebase Error (DeleteBudget): ${e.code} - ${e.message}');
      throw DatabaseFailure(e.message ?? 'Failed to delete budget.', code: e.code);
    } catch (e) {
      debugPrint('Firestore: Unknown Error (DeleteBudget): $e');
      throw const UnknownFailure('An unexpected error occurred while deleting budget.');
    }
  }
}
