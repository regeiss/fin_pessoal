import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/accounts/account_form_page.dart';
import 'package:fin_pessoal/presentation/transactions/transactions_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

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
              accountsAsync.when(
                data: (accounts) => _TotalBalance(
                  accounts: accounts,
                  transactions: transactionsAsync.valueOrNull ?? [],
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
                              color: isIncome ? Colors.green : Colors.red,
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

class _TotalBalance extends ConsumerWidget {
  const _TotalBalance({required this.accounts, required this.transactions});

  final List<Account> accounts;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Saldo total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              formatMoney(totalBalance(accounts, transactions)),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
