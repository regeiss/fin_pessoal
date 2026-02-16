// import 'package:drift/drift.dart';
import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive list of all transactions (newest first).
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(databaseProvider).watchAllTransactions();
});

/// Transactions in a date range (e.g. current month).
final transactionsInRangeProvider =
    FutureProvider.family<List<Transaction>, ({DateTime start, DateTime end})>((
      ref,
      range,
    ) {
      return ref
          .watch(databaseProvider)
          .getTransactionsInRange(range.start, range.end);
    });

/// Add a new transaction.
final addTransactionProvider = Provider<void Function(TransactionsCompanion)>((
  ref,
) {
  return (entry) {
    ref.read(databaseProvider).insertTransaction(entry);
  };
});

/// Update a transaction.
final updateTransactionProvider = Provider<void Function(Transaction)>((ref) {
  return (transaction) {
    ref.read(databaseProvider).updateTransaction(transaction);
  };
});

/// Delete a transaction.
final deleteTransactionProvider = Provider<void Function(Transaction)>((ref) {
  return (transaction) {
    ref.read(databaseProvider).deleteTransaction(transaction);
  };
});
