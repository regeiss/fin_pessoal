import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/budgets_provider.dart';
import 'package:fin_pessoal/core/providers/categories_provider.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/budgets/budget_form_page.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final categoriesAsync = ref.watch(categoriesByTypeProvider('expense'));
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final now = DateTime.now();
    final transactions = transactionsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        centerTitle: true,
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          return categoriesAsync.when(
            data: (expenseCategories) {
              if (expenseCategories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Nenhuma categoria de despesa. As categorias são criadas automaticamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                );
              }
              final budgetByCategory = {for (var b in budgets) b.categoryId: b};
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(budgetsStreamProvider);
                  ref.invalidate(transactionsStreamProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      _monthYearLabel(now),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...expenseCategories.map((category) {
                      final budget = budgetByCategory[category.id];
                      final spent = spentInCategoryForMonth(
                        category.id,
                        transactions,
                        year: now.year,
                        month: now.month,
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => BudgetFormPage(
                                category: category,
                                existingBudget: budget,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (budget != null)
                                      Text(
                                        '${formatMoney(spent)} / ${formatMoney(budget.amount)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: spent > budget.amount
                                              ? Colors.red
                                              : Colors.grey.shade700,
                                        ),
                                      )
                                    else
                                      Text(
                                        'Gasto: ${formatMoney(spent)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                                if (budget != null) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (spent / budget.amount).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        spent > budget.amount
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ] else
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Toque para definir um orçamento',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budgets',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const BudgetFormPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _monthYearLabel(DateTime date) {
  const months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
