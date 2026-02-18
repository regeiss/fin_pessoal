import 'package:fin_pessoal/data/database/app_database.dart';

/// Filters [transactions] to those within [start] (inclusive) and [end] (inclusive).
List<Transaction> transactionsInRange(
  List<Transaction> transactions, {
  required DateTime start,
  required DateTime end,
}) {
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
  return transactions
      .where((t) => !t.date.isBefore(startDay) && !t.date.isAfter(endDay))
      .toList();
}

/// Total income in [transactions].
double totalIncome(List<Transaction> transactions) {
  return transactions
      .where((t) => t.type == 'income')
      .fold<double>(0, (sum, t) => sum + t.amount);
}

/// Total expense in [transactions].
double totalExpense(List<Transaction> transactions) {
  return transactions
      .where((t) => t.type == 'expense')
      .fold<double>(0, (sum, t) => sum + t.amount);
}

/// Income and expense per month. Keys are "year-month" (e.g. "2025-01").
/// [transactions] should already be in the desired range.
Map<String, ({double income, double expense})> incomeExpenseByMonth(
  List<Transaction> transactions,
) {
  final map = <String, ({double income, double expense})>{};
  for (final t in transactions) {
    final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
    map.putIfAbsent(key, () => (income: 0, expense: 0));
    final current = map[key]!;
    if (t.type == 'income') {
      map[key] = (income: current.income + t.amount, expense: current.expense);
    } else {
      map[key] = (income: current.income, expense: current.expense + t.amount);
    }
  }
  return map;
}

/// Expense total per category. Keys are categoryId.
/// [transactions] should be expense-only or we filter to expense.
Map<int, double> expenseByCategory(List<Transaction> transactions) {
  final map = <int, double>{};
  for (final t in transactions) {
    if (t.type != 'expense') continue;
    map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
  }
  return map;
}

/// Returns list of months (year, month) from [start] to [end] inclusive, in chronological order.
List<(int year, int month)> monthsInRange(DateTime start, DateTime end) {
  final list = <(int, int)>[];
  var d = DateTime(start.year, start.month);
  final endMonth = DateTime(end.year, end.month);
  while (!d.isAfter(endMonth)) {
    list.add((d.year, d.month));
    d = DateTime(d.year, d.month + 1);
  }
  return list;
}
