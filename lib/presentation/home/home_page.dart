import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/theme/app_theme.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/core/utils/report_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/accounts/account_form_page.dart';
import 'package:fin_pessoal/presentation/transactions/transactions_page.dart';
import 'package:fin_pessoal/presentation/transactions/transaction_form_page.dart';
import 'package:fin_pessoal/presentation/budgets/budgets_page.dart';
import 'package:fin_pessoal/presentation/reports/reports_page.dart';

double _monthlyIncome(List<Transaction> transactions, int year, int month) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 0, 23, 59, 59);
  return transactions
      .where((t) => t.type == 'income' && !t.date.isBefore(start) && !t.date.isAfter(end))
      .fold<double>(0, (sum, t) => sum + t.amount);
}

double _monthlyExpense(List<Transaction> transactions, int year, int month) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 0, 23, 59, 59);
  return transactions
      .where((t) => t.type == 'expense' && !t.date.isBefore(start) && !t.date.isAfter(end))
      .fold<double>(0, (sum, t) => sum + t.amount);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final now = DateTime.now();
    final transactions = transactionsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fin Pessoal'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsStreamProvider);
          ref.invalidate(transactionsStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              transactionsAsync.when(
                data: (txs) => _DashboardChart(transactions: txs),
                loading: () => const Card(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              accountsAsync.when(
                data: (accounts) => _DashboardCards(
                  accounts: accounts,
                  transactions: transactions,
                  year: now.year,
                  month: now.month,
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Ações rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const _QuickActions(),
              const SizedBox(height: 24),
              const Text('Contas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) => accounts.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Nenhuma conta. Adicione uma conta para começar.'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length,
                        itemBuilder: (context, i) {
                          final a = accounts[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(a.name),
                              subtitle: Text(a.type),
                              trailing: Text(
                                formatMoney(accountBalance(a, transactionsAsync.valueOrNull ?? [])),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => AccountFormPage(account: a),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TransactionsPage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Últimas transações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Text('Ver todas', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              transactionsAsync.when(
                data: (txs) {
                  if (txs.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nenhuma transação ainda.'),
                      ),
                    );
                  }
                  final recent = txs.take(10).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (context, i) {
                      final t = recent[i];
                      final isIncome = t.type == 'income';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(t.note ?? 'Sem descrição'),
                          subtitle: Text(formatDate(t.date)),
                          trailing: Text(
                            '${isIncome ? '+' : '-'} ${formatMoney(t.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isIncome ? AppTheme.positiveColor(context) : AppTheme.negativeColor(context),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCards extends StatelessWidget {
  const _DashboardCards({
    required this.accounts,
    required this.transactions,
    required this.year,
    required this.month,
  });

  final List<Account> accounts;
  final List<Transaction> transactions;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final total = totalBalance(accounts, transactions);
    final income = _monthlyIncome(transactions, year, month);
    final expense = _monthlyExpense(transactions, year, month);
    final result = income - expense;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Saldo total',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, size: 14, color: AppTheme.positiveColor(context)),
                          const SizedBox(width: 4),
                          Text(
                            'Receitas',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(income),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.positiveColor(context),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward, size: 14, color: AppTheme.negativeColor(context)),
                          const SizedBox(width: 4),
                          Text(
                            'Despesas',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(expense),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.negativeColor(context),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado do mês',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                Text(
                  formatMoney(result),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: result >= 0 ? AppTheme.positiveColor(context) : AppTheme.negativeColor(context),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardChart extends StatelessWidget {
  const _DashboardChart({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = DateTime(now.year, now.month - 5, 1);
    final inRange = transactionsInRange(transactions, start: start, end: end);
    final byMonth = incomeExpenseByMonth(inRange);
    final months = monthsInRange(start, end);
    final maxVal = _chartMaxValue(byMonth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receitas x Despesas (últimos 6 meses)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: months.isEmpty
                  ? Center(
                      child: Text(
                        'Sem dados no período',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxVal * 1.2,
                        minY: -maxVal * 1.2,
                        barGroups: months.asMap().entries.map((e) {
                          final i = e.key;
                          final (year, month) = e.value;
                          final key = '$year-${month.toString().padLeft(2, '0')}';
                          final data = byMonth[key] ?? (income: 0.0, expense: 0.0);
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: data.income,
                                color: AppTheme.positiveColor(context),
                                width: 10,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                              BarChartRodData(
                                toY: -data.expense,
                                color: AppTheme.negativeColor(context),
                                width: 10,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                              ),
                            ],
                            barsSpace: 4,
                            showingTooltipIndicators: [],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text('0', style: TextStyle(fontSize: 9));
                                return Text(
                                  value > 0 ? formatMoney(value) : formatMoney(-value),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= months.length) return const SizedBox();
                                final (year, month) = months[i];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat('MM/yy').format(DateTime(year, month)),
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                      duration: const Duration(milliseconds: 250),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _chartMaxValue(Map<String, ({double income, double expense})> byMonth) {
    double m = 0;
    for (final v in byMonth.values) {
      if (v.income > m) m = v.income;
      if (v.expense > m) m = v.expense;
    }
    return m > 0 ? m : 1;
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.add_circle_outline,
            label: 'Nova transação',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TransactionFormPage()),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionChip(
            icon: Icons.account_balance_wallet,
            label: 'Nova conta',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AccountFormPage()),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionChip(
            icon: Icons.list_alt,
            label: 'Transações',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TransactionsPage()),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionChip(
            icon: Icons.pie_chart_outline,
            label: 'Orçamentos',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BudgetsPage()),
            ),
          ),
          const SizedBox(width: 10),
          _QuickActionChip(
            icon: Icons.analytics_outlined,
            label: 'Relatórios',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReportsPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

