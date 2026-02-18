import 'package:flutter/material.dart';
import 'package:fin_pessoal/presentation/credit_cards/credit_cards_page.dart';
import 'package:fin_pessoal/presentation/loans/loans_page.dart';
import 'package:fin_pessoal/presentation/bills/bills_page.dart';
import 'package:fin_pessoal/presentation/goals/goals_page.dart';
import 'package:fin_pessoal/presentation/reports/reports_page.dart';
import 'package:fin_pessoal/presentation/insights/insights_page.dart';
import 'package:fin_pessoal/presentation/financial_ai/financial_ai_page.dart';
import 'package:fin_pessoal/presentation/help/help_page.dart';
import 'package:fin_pessoal/presentation/settings/settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  static final _items = [
    _MoreItem(icon: Icons.credit_card, label: 'Cartões', builder: (_) => const CreditCardsPage()),
    _MoreItem(icon: Icons.handshake, label: 'Empréstimos', builder: (_) => const LoansPage()),
    _MoreItem(icon: Icons.receipt_long, label: 'Contas fixas', builder: (_) => const BillsPage()),
    _MoreItem(icon: Icons.flag, label: 'Metas', builder: (_) => const GoalsPage()),
    _MoreItem(icon: Icons.analytics_outlined, label: 'Relatórios', builder: (_) => const ReportsPage()),
    _MoreItem(icon: Icons.lightbulb_outline, label: 'Insights', builder: (_) => const InsightsPage()),
    _MoreItem(icon: Icons.smart_toy_outlined, label: 'IA financeira', builder: (_) => const FinancialAIPage()),
    _MoreItem(icon: Icons.help_outline, label: 'Ajuda', builder: (_) => const HelpPage()),
    _MoreItem(icon: Icons.settings, label: 'Configurações', builder: (_) => const SettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: item.builder),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({required this.icon, required this.label, required this.builder});
  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}
