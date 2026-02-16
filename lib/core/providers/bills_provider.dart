import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final billsStreamProvider = StreamProvider<List<Bill>>((ref) {
  return ref.watch(databaseProvider).watchAllBills();
});

final billsFutureProvider = FutureProvider<List<Bill>>((ref) {
  return ref.watch(databaseProvider).getAllBills();
});

final addBillProvider = Provider<void Function(BillsCompanion)>((ref) {
  return (entry) => ref.read(databaseProvider).insertBill(entry);
});

final updateBillProvider = Provider<void Function(Bill)>((ref) {
  return (bill) => ref.read(databaseProvider).updateBill(bill);
});

final deleteBillProvider = Provider<void Function(Bill)>((ref) {
  return (bill) => ref.read(databaseProvider).deleteBill(bill);
});
