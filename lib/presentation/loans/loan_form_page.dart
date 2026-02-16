import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/accounts_provider.dart';
import 'package:fin_pessoal/core/providers/loans_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/presentation/loans/loan_payment_form_page.dart';

class LoanFormPage extends ConsumerStatefulWidget {
  const LoanFormPage({super.key, this.loan});

  final Loan? loan;

  @override
  ConsumerState<LoanFormPage> createState() => _LoanFormPageState();
}

class _LoanFormPageState extends ConsumerState<LoanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _principalController = TextEditingController();
  final _interestController = TextEditingController(text: '0');
  final _dueDayController = TextEditingController();
  String _type = 'owed';
  DateTime _startDate = DateTime.now();
  int? _accountId;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      final l = widget.loan!;
      _nameController.text = l.name;
      _principalController.text = l.principal.toString();
      _interestController.text = l.interestRate?.toString() ?? '0';
      _dueDayController.text = l.dueDay?.toString() ?? '';
      _type = l.type;
      _startDate = l.startDate;
      _accountId = l.accountId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _interestController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.loan != null;
    final accountsAsync = ref.watch(accountsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar empréstimo' : 'Novo empréstimo'),
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
                hintText: 'Ex: Empréstimo banco, João',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 20),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'owed', label: Text('Eu devo'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'lent', label: Text('Me devem'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _principalController,
              decoration: const InputDecoration(
                labelText: 'Valor principal (R\$)',
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
              controller: _interestController,
              decoration: const InputDecoration(
                labelText: 'Taxa de juros % (opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Data início'),
              subtitle: Text(formatDate(_startDate)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _startDate = d);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dueDayController,
              decoration: const InputDecoration(
                labelText: 'Dia do vencimento (1-31, opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<int>(
                value: _accountId,
                decoration: const InputDecoration(
                  labelText: 'Conta relacionada (opcional)',
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Criar'),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Registrar pagamento'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LoanPaymentFormPage(loan: widget.loan!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final principal = double.tryParse(_principalController.text.replaceFirst(',', '.')) ?? 0;
    final interest = double.tryParse(_interestController.text.replaceFirst(',', '.'));
    final dueDay = int.tryParse(_dueDayController.text);
    final dueDayValid = dueDay != null && dueDay >= 1 && dueDay <= 31 ? dueDay : null;

    if (widget.loan != null) {
      ref.read(updateLoanProvider)(Loan(
        id: widget.loan!.id,
        name: name,
        type: _type,
        principal: principal,
        interestRate: interest,
        startDate: _startDate,
        dueDay: dueDayValid,
        accountId: _accountId,
        createdAt: widget.loan!.createdAt,
      ));
    } else {
      ref.read(addLoanProvider)(LoansCompanion.insert(
        name: name,
        type: _type,
        principal: principal,
        interestRate: Value(interest),
        startDate: _startDate,
        dueDay: Value(dueDayValid),
        accountId: Value(_accountId),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.loan == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir empréstimo?'),
        content: const Text('Os pagamentos registrados também serão perdidos.'),
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
      ref.read(deleteLoanProvider)(widget.loan!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
