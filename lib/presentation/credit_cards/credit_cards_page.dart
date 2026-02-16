import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/credit_cards_provider.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/credit_cards/credit_card_form_page.dart';

class CreditCardsPage extends ConsumerWidget {
  const CreditCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardsStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final transactions = transactionsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões de crédito'),
        centerTitle: true,
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum cartão',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque em + para cadastrar um cartão.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(creditCardsStreamProvider);
              ref.invalidate(transactionsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final card = cards[i];
                final balance = creditCardBalance(card.id, transactions);
                final available = card.creditLimit - balance;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    title: Text(card.name),
                    subtitle: Text(
                      card.lastFourDigits != null
                          ? '•••• ${card.lastFourDigits}'
                          : 'Fechamento: dia ${card.closingDay} · Vencimento: dia ${card.dueDay}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatMoney(balance),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: balance > 0 ? Colors.red : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'disponível ${formatMoney(available)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => CreditCardFormPage(card: card),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erro: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_credit_cards',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const CreditCardFormPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
