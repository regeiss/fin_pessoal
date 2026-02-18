import 'package:fin_pessoal/core/theme/app_theme.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/core/utils/report_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum ReportPeriod {
  thisMonth,
  last3Months,
  last6Months,
  last12Months,
}

extension ReportPeriodExt on ReportPeriod {
  String get label {
    return switch (this) {
      ReportPeriod.thisMonth => 'Este mês',
      ReportPeriod.last3Months => 'Últimos 3 meses',
      ReportPeriod.last6Months => 'Últimos 6 meses',
      ReportPeriod.last12Months => 'Últimos 12 meses',
    };
  }

  (DateTime start, DateTime end) range(DateTime now) {
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = switch (this) {
      ReportPeriod.thisMonth => DateTime(now.year, now.month, 1),
      ReportPeriod.last3Months => DateTime(now.year, now.month - 2, 1),
      ReportPeriod.last6Months => DateTime(now.year, now.month - 5, 1),
      ReportPeriod.last12Months => DateTime(now.year, now.month - 11, 1),
    };
    return (start, end);
  }
}

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportPeriod _period = ReportPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final now = DateTime.now();
    final (start, end) = _period.range(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        centerTitle: true,
      ),
      body: transactionsAsync.when(
        data: (allTransactions) {
          final inRange = transactionsInRange(allTransactions, start: start, end: end);
          final income = totalIncome(inRange);
          final expense = totalExpense(inRange);
          final byMonth = incomeExpenseByMonth(inRange);
          final months = monthsInRange(start, end);
          final expenseByCat = expenseByCategory(inRange);

          return categoriesAsync.when(
            data: (categories) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(transactionsStreamProvider);
                  ref.invalidate(categoriesStreamProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PeriodSelector(
                        value: _period,
                        onChanged: (p) => setState(() => _period = p),
                      ),
                      const SizedBox(height: 20),
                      _SummaryCards(
                        income: income,
                        expense: expense,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Receitas x Despesas por mês'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: _IncomeExpenseBarChart(
                          months: months,
                          byMonth: byMonth,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: 'Despesas por categoria'),
                      const SizedBox(height: 12),
                      if (expenseByCat.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('Nenhuma despesa no período.'),
                          ),
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: _ExpenseByCategoryChart(
                            expenseByCategory: expenseByCat,
                            categories: categories,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.value,
    required this.onChanged,
  });

  final ReportPeriod value;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReportPeriod>(
      segments: ReportPeriod.values
          .map((p) => ButtonSegment<ReportPeriod>(value: p, label: Text(p.label)))
          .toList(),
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Receitas',
            value: formatMoney(income),
            color: AppTheme.positiveColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Despesas',
            value: formatMoney(expense),
            color: AppTheme.negativeColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Saldo',
            value: formatMoney(balance),
            color: balance >= 0 ? AppTheme.positiveColor(context) : AppTheme.negativeColor(context),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _IncomeExpenseBarChart extends StatelessWidget {
  const _IncomeExpenseBarChart({
    required this.months,
    required this.byMonth,
  });

  final List<(int year, int month)> months;
  final Map<String, ({double income, double expense})> byMonth;

  @override
  Widget build(BuildContext context) {
    final maxVal = _maxValue(byMonth);
    final positiveColor = AppTheme.positiveColor(context);
    final negativeColor = AppTheme.negativeColor(context);

    final groups = months.asMap().entries.map((e) {
      final i = e.key;
      final (year, month) = e.value;
      final key = '$year-${month.toString().padLeft(2, '0')}';
      final data = byMonth[key] ?? (income: 0.0, expense: 0.0);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data.income,
            color: positiveColor,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: -data.expense,
            color: negativeColor,
            width: 12,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
          ),
        ],
        barsSpace: 4,
        showingTooltipIndicators: [],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        minY: -maxVal * 1.2,
        barGroups: groups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('0');
                return Text(
                  value > 0 ? formatMoney(value) : formatMoney(-value),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= months.length) return const SizedBox();
                final (year, month) = months[i];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MM/yy').format(DateTime(year, month)),
                    style: TextStyle(
                      fontSize: 10,
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
    );
  }

  double _maxValue(Map<String, ({double income, double expense})> byMonth) {
    double m = 0;
    for (final v in byMonth.values) {
      if (v.income > m) m = v.income;
      if (v.expense > m) m = v.expense;
    }
    return m > 0 ? m : 1;
  }
}

class _ExpenseByCategoryChart extends StatelessWidget {
  const _ExpenseByCategoryChart({
    required this.expenseByCategory,
    required this.categories,
  });

  final Map<int, double> expenseByCategory;
  final List<Category> categories;

  static const _chartColors = [
    Color(0xFF0D47A1),
    Color(0xFF00695C),
    Color(0xFF7B1FA2),
    Color(0xFFE65100),
    Color(0xFF00838F),
    Color(0xFF558B2F),
    Color(0xFF6A1B9A),
    Color(0xFFAD1457),
  ];

  @override
  Widget build(BuildContext context) {
    final total = expenseByCategory.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      return const Center(child: Text('Nenhuma despesa.'));
    }

    final sortedEntries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categoryNames = {for (final c in categories) c.id: c.name};

    final sections = sortedEntries.asMap().entries.map((e) {
      final i = e.key;
      final amount = e.value.value;
      return PieChartSectionData(
        value: amount,
        title: '${(amount / total * 100).toStringAsFixed(0)}%',
        color: _chartColors[i % _chartColors.length],
        radius: 48,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.length,
            itemBuilder: (context, i) {
              final e = sortedEntries[i];
              final name = categoryNames[e.key] ?? 'Categoria #${e.key}';
              final pct = e.value / total * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _chartColors[i % _chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
