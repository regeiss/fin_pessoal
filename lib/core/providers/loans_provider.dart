import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loansStreamProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(databaseProvider).watchAllLoans();
});

final loansFutureProvider = FutureProvider<List<Loan>>((ref) {
  return ref.watch(databaseProvider).getAllLoans();
});

final loanPaymentsProvider = FutureProvider.family<List<LoanPayment>, int>((ref, loanId) {
  return ref.watch(databaseProvider).getPaymentsByLoan(loanId);
});

final addLoanProvider = Provider<void Function(LoansCompanion)>((ref) {
  return (entry) => ref.read(databaseProvider).insertLoan(entry);
});

final updateLoanProvider = Provider<void Function(Loan)>((ref) {
  return (loan) => ref.read(databaseProvider).updateLoan(loan);
});

final deleteLoanProvider = Provider<void Function(Loan)>((ref) {
  return (loan) => ref.read(databaseProvider).deleteLoanAndPayments(loan);
});

final addLoanPaymentProvider = Provider<void Function(LoanPaymentsCompanion)>((ref) {
  return (entry) => ref.read(databaseProvider).insertLoanPayment(entry);
});

final deleteLoanPaymentProvider = Provider<void Function(LoanPayment)>((ref) {
  return (p) => ref.read(databaseProvider).deleteLoanPayment(p);
});
