import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/loans_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class LoanPaymentFormPage extends ConsumerStatefulWidget {
  const LoanPaymentFormPage({super.key, required this.loan});

  final Loan loan;

  @override
  ConsumerState<LoanPaymentFormPage> createState() => _LoanPaymentFormPageState();
}

class _LoanPaymentFormPageState extends ConsumerState<LoanPaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(loanPaymentsProvider(widget.loan.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar pagamento'),
      ),
      body: paymentsAsync.when(
        data: (payments) {
          final balance = loanBalance(widget.loan, payments);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.loan.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Saldo atual: ${formatMoney(balance)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o valor';
                    final n = double.tryParse(v.replaceFirst(',', '.'));
                    if (n == null || n <= 0) return 'Valor deve ser maior que zero';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Data'),
                  subtitle: Text(formatDate(_date)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final amount = double.tryParse(_amountController.text.replaceFirst(',', '.')) ?? 0;
                    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
                    ref.read(addLoanPaymentProvider)(LoanPaymentsCompanion.insert(
                          loanId: widget.loan.id,
                          amount: amount,
                          date: _date,
                          note: Value(note),
                        ));
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Registrar'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
