import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive list of all budgets.
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(databaseProvider).watchAllBudgets();
});

/// One-time fetch of all budgets.
final budgetsFutureProvider = FutureProvider<List<Budget>>((ref) {
  return ref.watch(databaseProvider).getAllBudgets();
});

/// Add a new budget.
final addBudgetProvider = Provider<void Function(BudgetsCompanion)>((ref) {
  return (entry) {
    ref.read(databaseProvider).insertBudget(entry);
  };
});

/// Update a budget.
final updateBudgetProvider = Provider<void Function(Budget)>((ref) {
  return (budget) {
    ref.read(databaseProvider).updateBudget(budget);
  };
});

/// Delete a budget.
final deleteBudgetProvider = Provider<void Function(Budget)>((ref) {
  return (budget) {
    ref.read(databaseProvider).deleteBudget(budget);
  };
});
