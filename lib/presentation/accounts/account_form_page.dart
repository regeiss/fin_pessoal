import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class AccountFormPage extends ConsumerStatefulWidget {
  const AccountFormPage({super.key, this.account});

  final Account? account;

  @override
  ConsumerState<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends ConsumerState<AccountFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');
  String _type = 'bank';

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _initialBalanceController.text = widget.account!.initialBalance.toString();
      _type = widget.account!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar conta' : 'Nova conta'),
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
                hintText: 'Ex: Nubank, Carteira',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome';
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'bank', label: Text('Banco'), icon: Icon(Icons.account_balance)),
                ButtonSegment(value: 'cash', label: Text('Dinheiro'), icon: Icon(Icons.payments)),
                ButtonSegment(value: 'savings', label: Text('Poupança'), icon: Icon(Icons.savings)),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> selected) => setState(() => _type = selected.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _initialBalanceController,
              decoration: const InputDecoration(
                labelText: 'Saldo inicial (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o saldo';
                if (double.tryParse(v.replaceFirst(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Criar conta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final balance = double.tryParse(_initialBalanceController.text.replaceFirst(',', '.')) ?? 0;

    if (widget.account != null) {
      final updated = Account(
        id: widget.account!.id,
        name: name,
        type: _type,
        initialBalance: balance,
        currency: widget.account!.currency,
        createdAt: widget.account!.createdAt,
      );
      ref.read(updateAccountProvider)(updated);
    } else {
      ref.read(addAccountProvider)(
        AccountsCompanion.insert(
          name: name,
          type: Value(_type),
          initialBalance: Value(balance),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: Text(
          'Excluir "${widget.account!.name}"? Transações vinculadas permanecem, mas sem conta associada.',
        ),
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
    if (ok == true && mounted) {
      ref.read(deleteAccountProvider)(widget.account!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
