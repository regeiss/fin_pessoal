import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/credit_cards_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class CreditCardFormPage extends ConsumerStatefulWidget {
  const CreditCardFormPage({super.key, this.card});

  final CreditCard? card;

  @override
  ConsumerState<CreditCardFormPage> createState() => _CreditCardFormPageState();
}

class _CreditCardFormPageState extends ConsumerState<CreditCardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _limitController = TextEditingController();
  final _closingDayController = TextEditingController(text: '10');
  final _dueDayController = TextEditingController(text: '17');
  int? _accountId;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      final c = widget.card!;
      _nameController.text = c.name;
      _lastFourController.text = c.lastFourDigits ?? '';
      _limitController.text = c.creditLimit.toString();
      _closingDayController.text = c.closingDay.toString();
      _dueDayController.text = c.dueDay.toString();
      _accountId = c.accountId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastFourController.dispose();
    _limitController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  int? _parseDay(String value) {
    final n = int.tryParse(value);
    if (n == null || n < 1 || n > 31) return null;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.card != null;
    final accountsAsync = ref.watch(accountsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar cartão' : 'Novo cartão'),
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
                labelText: 'Nome do cartão',
                hintText: 'Ex: Nubank, Itaú',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _lastFourController,
              decoration: const InputDecoration(
                labelText: 'Últimos 4 dígitos (opcional)',
                hintText: 'Ex: 1234',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(
                labelText: 'Limite (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o limite';
                if (double.tryParse(v.replaceFirst(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _closingDayController,
                    decoration: const InputDecoration(
                      labelText: 'Dia fechamento',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obrigatório';
                      if (_parseDay(v) == null) return '1-31';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dueDayController,
                    decoration: const InputDecoration(
                      labelText: 'Dia vencimento',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obrigatório';
                      if (_parseDay(v) == null) return '1-31';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            accountsAsync.when(
              data: (accounts) {
                return DropdownButtonFormField<int>(
                  value: _accountId,
                  decoration: const InputDecoration(
                    labelText: 'Conta para pagar a fatura (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('Nenhuma')),
                    ...accounts.map((a) => DropdownMenuItem<int>(value: a.id, child: Text(a.name))),
                  ],
                  onChanged: (v) => setState(() => _accountId = v),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Cadastrar cartão'),
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
    final lastFour = _lastFourController.text.trim().isEmpty ? null : _lastFourController.text.trim();
    final limit = double.tryParse(_limitController.text.replaceFirst(',', '.')) ?? 0;
    final closingDay = _parseDay(_closingDayController.text)!;
    final dueDay = _parseDay(_dueDayController.text)!;

    if (widget.card != null) {
      final updated = CreditCard(
        id: widget.card!.id,
        name: name,
        lastFourDigits: lastFour,
        creditLimit: limit,
        closingDay: closingDay,
        dueDay: dueDay,
        accountId: _accountId,
        createdAt: widget.card!.createdAt,
      );
      ref.read(updateCreditCardProvider)(updated);
    } else {
      ref.read(addCreditCardProvider)(
        CreditCardsCompanion.insert(
          name: name,
          lastFourDigits: Value(lastFour),
          creditLimit: limit,
          closingDay: closingDay,
          dueDay: dueDay,
          accountId: Value(_accountId),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cartão?'),
        content: Text(
          'Excluir "${widget.card!.name}"? As transações vinculadas permanecem, mas sem cartão associado.',
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
      ref.read(deleteCreditCardProvider)(widget.card!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
