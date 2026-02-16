import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:intl/intl.dart';

String formatMoney(double value) {
  return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Current balance of an account from initial balance + transactions.
double accountBalance(Account account, List<Transaction> transactions) {
  final forAccount = transactions.where((t) => t.accountId == account.id).toList();
  double balance = account.initialBalance;
  for (final t in forAccount) {
    if (t.type == 'income') balance += t.amount;
    else balance -= t.amount;
  }
  return balance;
}

/// Total balance across all accounts (initial + sum of transactions).
double totalBalance(List<Account> accounts, List<Transaction> transactions) {
  return accounts.fold<double>(
    0,
    (sum, a) => sum + accountBalance(a, transactions),
  );
}

/// Current balance (debt) on a credit card = sum of expenses linked to this card.
double creditCardBalance(int creditCardId, List<Transaction> transactions) {
  return transactions
      .where((t) => t.creditCardId == creditCardId && t.type == 'expense')
      .fold<double>(0, (sum, t) => sum + t.amount);
}

/// Remaining balance on a loan: principal minus sum of payments.
double loanBalance(Loan loan, List<LoanPayment> payments) {
  final paid = payments.fold<double>(0, (sum, p) => sum + p.amount);
  return loan.principal - paid;
}

/// Total spent in a category for a given month (expenses only).
double spentInCategoryForMonth(
  int categoryId,
  List<Transaction> transactions, {
  required int year,
  required int month,
}) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 0, 23, 59, 59);
  return transactions
      .where((t) =>
          t.categoryId == categoryId &&
          t.type == 'expense' &&
          !t.date.isBefore(start) &&
          !t.date.isAfter(end))
      .fold<double>(0, (sum, t) => sum + t.amount);
}
