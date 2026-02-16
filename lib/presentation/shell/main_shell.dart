import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/constants/breakpoints.dart';
import 'package:fin_pessoal/presentation/home/home_page.dart';
import 'package:fin_pessoal/presentation/transactions/transactions_page.dart';
import 'package:fin_pessoal/presentation/accounts/accounts_page.dart';
import 'package:fin_pessoal/presentation/credit_cards/credit_cards_page.dart';
import 'package:fin_pessoal/presentation/budgets/budgets_page.dart';
import 'package:fin_pessoal/presentation/loans/loans_page.dart';
import 'package:fin_pessoal/presentation/bills/bills_page.dart';
import 'package:fin_pessoal/presentation/goals/goals_page.dart';
import 'package:fin_pessoal/presentation/more/more_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _bottomTabs = [
    _NavItem(icon: Icons.home, label: 'Início'),
    _NavItem(icon: Icons.list_alt, label: 'Transações'),
    _NavItem(icon: Icons.pie_chart_outline, label: 'Orçamentos'),
    _NavItem(icon: Icons.account_balance_wallet, label: 'Contas'),
    _NavItem(icon: Icons.more_horiz, label: 'Mais'),
  ];

  static const _railTabs = [
    _NavItem(icon: Icons.home, label: 'Início'),
    _NavItem(icon: Icons.list_alt, label: 'Transações'),
    _NavItem(icon: Icons.pie_chart_outline, label: 'Orçamentos'),
    _NavItem(icon: Icons.account_balance_wallet, label: 'Contas'),
    _NavItem(icon: Icons.credit_card, label: 'Cartões'),
    _NavItem(icon: Icons.handshake, label: 'Empréstimos'),
    _NavItem(icon: Icons.receipt_long, label: 'Contas fixas'),
    _NavItem(icon: Icons.flag, label: 'Metas'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useTabletLayout = width >= kTabletBreakpoint;

    final bottomPages = [
      const HomePage(),
      const TransactionsPage(),
      const BudgetsPage(),
      const AccountsPage(),
      const MorePage(),
    ];

    final railPages = [
      const HomePage(),
      const TransactionsPage(),
      const BudgetsPage(),
      const AccountsPage(),
      const CreditCardsPage(),
      const LoansPage(),
      const BillsPage(),
      const GoalsPage(),
    ];

    if (useTabletLayout) {
      final railIndex = _currentIndex > 7 ? 0 : _currentIndex;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: width >= 840,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Icon(
                  Icons.account_balance,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              selectedIndex: railIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: width >= 840 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              destinations: _railTabs
                  .map((e) => NavigationRailDestination(
                        icon: Icon(e.icon),
                        label: Text(e.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: railIndex,
                children: railPages,
              ),
            ),
          ],
        ),
      );
    }

    final bottomIndex = _currentIndex > 4 ? 4 : _currentIndex;
    return Scaffold(
      body: IndexedStack(
        index: bottomIndex,
        children: bottomPages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: bottomIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _bottomTabs
            .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.label))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
