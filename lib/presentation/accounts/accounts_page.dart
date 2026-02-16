import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/accounts/account_form_page.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final transactions = transactionsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
        centerTitle: true,
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma conta',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque em + para adicionar sua primeira conta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(accountsStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, i) {
                final a = accounts[i];
                final balance = accountBalance(a, transactions);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(a.name),
                    subtitle: Text(_typeLabel(a.type)),
                    trailing: Text(
                      formatMoney(balance),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => _openForm(context, account: a),
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
        heroTag: 'fab_accounts',
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, {Account? account}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AccountFormPage(account: account),
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'bank':
      return 'Banco';
    case 'cash':
      return 'Dinheiro';
    case 'savings':
      return 'Poupança';
    default:
      return type;
  }
}
