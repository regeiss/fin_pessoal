// import 'package:drift/drift.dart';
import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive list of all accounts.
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(databaseProvider).watchAllAccounts();
});

/// One-time fetch of all accounts (e.g. for dropdowns in forms).
final accountsFutureProvider = FutureProvider<List<Account>>((ref) {
  return ref.watch(databaseProvider).getAllAccounts();
});

/// Add a new account.
final addAccountProvider = Provider<void Function(AccountsCompanion)>((ref) {
  return (entry) {
    ref.read(databaseProvider).insertAccount(entry);
  };
});

/// Update an existing account.
final updateAccountProvider = Provider<void Function(Account)>((ref) {
  return (account) {
    ref.read(databaseProvider).updateAccount(account);
  };
});

/// Delete an account.
final deleteAccountProvider = Provider<void Function(Account)>((ref) {
  return (account) {
    ref.read(databaseProvider).deleteAccount(account);
  };
});
