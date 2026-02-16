import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/goals_provider.dart';
import 'package:fin_pessoal/core/utils/format_utils.dart';
import 'package:fin_pessoal/data/database/app_database.dart';

class GoalFormPage extends ConsumerStatefulWidget {
  const GoalFormPage({super.key, this.goal});

  final Goal? goal;

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      final g = widget.goal!;
      _nameController.text = g.name;
      _targetController.text = g.targetAmount.toString();
      _currentController.text = g.currentAmount.toString();
      _deadline = g.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar meta' : 'Nova meta'),
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
                labelText: 'Nome da meta',
                hintText: 'Ex: Reserva de emergência, Viagem',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Valor alvo (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor alvo';
                if (double.tryParse(v.replaceFirst(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _currentController,
              decoration: const InputDecoration(
                labelText: 'Valor atual (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor atual';
                if (double.tryParse(v.replaceFirst(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Data limite (opcional)'),
              subtitle: Text(_deadline != null ? formatDate(_deadline!) : 'Nenhuma'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              trailing: _deadline != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _deadline = null),
                    )
                  : null,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _deadline = d);
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(isEditing ? 'Salvar' : 'Criar meta'),
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
    final target = double.tryParse(_targetController.text.replaceFirst(',', '.')) ?? 0;
    final current = double.tryParse(_currentController.text.replaceFirst(',', '.')) ?? 0;

    if (widget.goal != null) {
      ref.read(updateGoalProvider)(Goal(
        id: widget.goal!.id,
        name: name,
        targetAmount: target,
        currentAmount: current,
        deadline: _deadline,
        createdAt: widget.goal!.createdAt,
      ));
    } else {
      ref.read(addGoalProvider)(GoalsCompanion.insert(
        name: name,
        targetAmount: target,
        currentAmount: Value(current),
        deadline: Value(_deadline),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.goal == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: Text('Excluir "${widget.goal!.name}"?'),
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
      ref.read(deleteGoalProvider)(widget.goal!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
