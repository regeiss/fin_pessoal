import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/budgets_provider.dart';
import 'package:fin_pessoal/core/providers/categories_provider.dart';
import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class BudgetFormPage extends ConsumerStatefulWidget {
  const BudgetFormPage({super.key, this.category, this.existingBudget});

  /// When null, user must pick a category.
  final Category? category;
  final Budget? existingBudget;

  @override
  ConsumerState<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends ConsumerState<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    if (widget.existingBudget != null) {
      _amountController.text = widget.existingBudget!.amount.toString();
      _categoryId = widget.existingBudget!.categoryId;
    } else if (widget.category != null) {
      _categoryId = widget.category!.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBudget != null;
    final categoriesAsync = ref.watch(categoriesByTypeProvider('expense'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar orçamento' : (widget.category != null ? 'Definir orçamento' : 'Novo orçamento'),
        ),
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
            if (widget.category == null && !isEditing) ...[
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const ListTile(
                      title: Text('Nenhuma categoria de despesa.'),
                    );
                  }
                  if (_categoryId == null && categories.isNotEmpty) _categoryId = categories.first.id;
                  return DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Selecione a categoria' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              const SizedBox(height: 20),
            ] else if (widget.category != null || isEditing)
              ListTile(
                title: const Text('Categoria'),
                subtitle: Text(
                  widget.category?.name ??
                      categoriesAsync.valueOrNull
                          ?.where((c) => c.id == _categoryId)
                          .firstOrNull
                          ?.name ??
                      '—',
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Limite mensal (R\$)',
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Definir orçamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceFirst(',', '.')) ?? 0;
    final categoryId = _categoryId ?? widget.category?.id ?? widget.existingBudget?.categoryId;
    if (categoryId == null) return;

    if (widget.existingBudget != null) {
      final updated = Budget(
        id: widget.existingBudget!.id,
        categoryId: categoryId,
        amount: amount,
        createdAt: widget.existingBudget!.createdAt,
      );
      ref.read(updateBudgetProvider)(updated);
    } else {
      // One budget per category: update if exists, else insert
      final existing = await ref.read(databaseProvider).getBudgetByCategoryId(categoryId);
      if (existing != null) {
        ref.read(updateBudgetProvider)(Budget(
          id: existing.id,
          categoryId: existing.categoryId,
          amount: amount,
          createdAt: existing.createdAt,
        ));
      } else {
        ref.read(addBudgetProvider)(
          BudgetsCompanion.insert(
            categoryId: categoryId,
            amount: amount,
          ),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.existingBudget == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir orçamento?'),
        content: const Text('O limite desta categoria será removido.'),
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
      ref.read(deleteBudgetProvider)(widget.existingBudget!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
