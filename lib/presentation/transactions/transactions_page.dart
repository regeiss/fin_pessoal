import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/transactions/transaction_form_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        centerTitle: true,
      ),
      body: transactionsAsync.when(
        data: (txs) {
          if (txs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma transação',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque em + para registrar receita ou despesa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transactionsStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: txs.length,
              itemBuilder: (context, i) {
                final t = txs[i];
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
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => TransactionFormPage(transaction: t),
                      ),
                    ),
                    onLongPress: () => _confirmDelete(context, ref, t),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const TransactionFormPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Transaction t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(deleteTransactionProvider)(t);
  }
}
