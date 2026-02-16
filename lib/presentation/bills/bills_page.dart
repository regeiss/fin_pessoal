import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/bills_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/bills/bill_form_page.dart';

class BillsPage extends ConsumerWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas fixas'),
        centerTitle: true,
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma conta fixa',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre contas que se repetem (luz, aluguel, assinaturas).',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(billsStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              itemBuilder: (context, i) {
                final bill = bills[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: bill.isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.receipt,
                        color: bill.isActive
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      bill.name,
                      style: TextStyle(
                        decoration: bill.isActive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      'Vencimento: dia ${bill.dueDay} · ${bill.frequency == 'yearly' ? 'Anual' : 'Mensal'}',
                    ),
                    trailing: Text(
                      formatMoney(bill.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BillFormPage(bill: bill),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_bills',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BillFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
