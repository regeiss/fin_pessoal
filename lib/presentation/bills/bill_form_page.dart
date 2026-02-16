import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/bills_provider.dart';
import 'package:fin_pessoal/core/providers/categories_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class BillFormPage extends ConsumerStatefulWidget {
  const BillFormPage({super.key, this.bill});

  final Bill? bill;

  @override
  ConsumerState<BillFormPage> createState() => _BillFormPageState();
}

class _BillFormPageState extends ConsumerState<BillFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDayController = TextEditingController(text: '10');
  String _frequency = 'monthly';
  int? _categoryId;
  int? _accountId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      final b = widget.bill!;
      _nameController.text = b.name;
      _amountController.text = b.amount.toString();
      _dueDayController.text = b.dueDay.toString();
      _frequency = b.frequency;
      _categoryId = b.categoryId;
      _accountId = b.accountId;
      _isActive = b.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bill != null;
    final accountsAsync = ref.watch(accountsFutureProvider);
    final categoriesAsync = ref.watch(categoriesByTypeProvider('expense'));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar conta fixa' : 'Nova conta fixa'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: Luz, Aluguel, Netflix',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                if (double.tryParse(v.replaceFirst(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dueDayController,
              decoration: const InputDecoration(
                labelText: 'Dia do vencimento (1-31)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o dia';
                final d = int.tryParse(v);
                if (d == null || d < 1 || d > 31) return 'Dia entre 1 e 31';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'monthly', label: Text('Mensal')),
                ButtonSegment(value: 'yearly', label: Text('Anual')),
              ],
              selected: {_frequency},
              onSelectionChanged: (s) => setState(() => _frequency = s.first),
            ),
            const SizedBox(height: 20),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoria (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('Nenhuma')),
                  ...categories.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<int>(
                value: _accountId,
                decoration: const InputDecoration(
                  labelText: 'Conta para pagar (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('Nenhuma')),
                  ...accounts.map((a) => DropdownMenuItem<int>(value: a.id, child: Text(a.name))),
                ],
                onChanged: (v) => setState(() => _accountId = v),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (isEditing) ...[
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Ativa'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceFirst(',', '.')) ?? 0;
    final dueDay = int.parse(_dueDayController.text);

    if (widget.bill != null) {
      ref.read(updateBillProvider)(Bill(
        id: widget.bill!.id,
        name: name,
        amount: amount,
        dueDay: dueDay,
        frequency: _frequency,
        categoryId: _categoryId,
        accountId: _accountId,
        isActive: _isActive,
        createdAt: widget.bill!.createdAt,
      ));
    } else {
      ref.read(addBillProvider)(BillsCompanion.insert(
        name: name,
        amount: amount,
        dueDay: dueDay,
        frequency: Value(_frequency),
        categoryId: Value(_categoryId),
        accountId: Value(_accountId),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.bill == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta fixa?'),
        content: Text('Excluir "${widget.bill!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ref.read(deleteBillProvider)(widget.bill!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
