import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/categories_provider.dart';
import 'package:fin_pessoal/core/providers/credit_cards_provider.dart';
import 'package:fin_pessoal/core/providers/transactions_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key, this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  int? _accountId;
  int? _categoryId;
  int? _creditCardId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _type = t.type;
      _accountId = t.accountId;
      _categoryId = t.categoryId;
      _creditCardId = t.creditCardId;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final accountsAsync = ref.watch(accountsFutureProvider);
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar transação' : 'Nova transação'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Despesa'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Receita'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> selected) {
                setState(() {
                  _type = selected.first;
                  _categoryId = null;
                  if (_type == 'income') _creditCardId = null;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                final n = double.tryParse(v.replaceFirst(',', '.'));
                if (n == null || n <= 0) return 'Valor deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 20),
            accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const ListTile(
                    title: Text('Nenhuma conta. Crie uma conta primeiro.'),
                  );
                }
                if (_accountId == null && accounts.isNotEmpty)
                  _accountId = accounts.first.id;
                return DropdownButtonFormField<int>(
                  initialValue: _accountId,
                  decoration: const InputDecoration(
                    labelText: 'Conta',
                    border: OutlineInputBorder(),
                  ),
                  items: accounts
                      .map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _accountId = v),
                  validator: (v) => v == null ? 'Selecione a conta' : null,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Erro: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 20),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                if (_categoryId == null && categories.isNotEmpty)
                  _categoryId = categories.first.id;
                return DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Selecione a categoria' : null,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Erro: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            if (_type == 'expense') ...[
              const SizedBox(height: 20),
              ref
                  .watch(creditCardsFutureProvider)
                  .when(
                    data: (cards) {
                      if (cards.isEmpty) return const SizedBox.shrink();
                      return DropdownButtonFormField<int>(
                        initialValue: _creditCardId,
                        decoration: const InputDecoration(
                          labelText: 'Cartão de crédito (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Nenhum'),
                          ),
                          ...cards.map(
                            (c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(
                                c.lastFourDigits != null
                                    ? '${c.name} •••• ${c.lastFourDigits}'
                                    : c.name,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _creditCardId = v),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ],
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Data'),
              subtitle: Text(formatDate(_date)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Ex: Supermercado, Salário',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.tryParse(_amountController.text.replaceFirst(',', '.')) ?? 0;
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (_accountId == null || _categoryId == null) return;

    if (widget.transaction != null) {
      final updated = Transaction(
        id: widget.transaction!.id,
        amount: amount,
        date: _date,
        accountId: _accountId!,
        categoryId: _categoryId!,
        note: note,
        type: _type,
        creditCardId: _creditCardId,
        createdAt: widget.transaction!.createdAt,
      );
      ref.read(updateTransactionProvider)(updated);
    } else {
      ref.read(addTransactionProvider)(
        TransactionsCompanion.insert(
          amount: amount,
          date: _date,
          accountId: _accountId!,
          categoryId: _categoryId!,
          note: Value(note),
          type: _type,
          creditCardId: Value(_creditCardId),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
