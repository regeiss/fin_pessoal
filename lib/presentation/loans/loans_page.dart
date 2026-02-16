import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/loans_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/loans/loan_form_page.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empréstimos'),
        centerTitle: true,
      ),
      body: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handshake_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum empréstimo',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registre empréstimos que você deve ou que emprestou.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(loansStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: loans.length,
              itemBuilder: (context, i) {
                final loan = loans[i];
                return _LoanCard(loan: loan);
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
        heroTag: 'fab_loans',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LoanFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LoanCard extends ConsumerWidget {
  const _LoanCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(loanPaymentsProvider(loan.id));

    return paymentsAsync.when(
      data: (payments) {
        final balance = loanBalance(loan, payments);
        final isOwed = loan.type == 'owed';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isOwed ? Colors.orange.shade100 : Colors.green.shade100,
              child: Icon(
                isOwed ? Icons.arrow_upward : Icons.arrow_downward,
                color: isOwed ? Colors.orange : Colors.green,
              ),
            ),
            title: Text(loan.name),
            subtitle: Text(
              isOwed ? 'Você deve' : 'Te devem',
              style: TextStyle(
                color: isOwed ? Colors.orange.shade700 : Colors.green.shade700,
                fontSize: 12,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(balance),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: balance > 0 ? (isOwed ? Colors.orange : Colors.green) : Colors.grey,
                  ),
                ),
                Text(
                  'de ${formatMoney(loan.principal)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LoanFormPage(loan: loan),
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text('…'),
          trailing: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
