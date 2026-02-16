// import 'package:drift/drift.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
// import 'package:flutter/material.dart';

/// Default categories to insert when the app has none.
List<CategoriesCompanion> get defaultCategories => [
  // Income
  CategoriesCompanion.insert(name: 'Salário', type: 'income'),
  CategoriesCompanion.insert(name: 'Freelance', type: 'income'),
  CategoriesCompanion.insert(name: 'Investimentos', type: 'income'),
  CategoriesCompanion.insert(name: 'Outros (receita)', type: 'income'),
  // Expense
  CategoriesCompanion.insert(name: 'Alimentação', type: 'expense'),
  CategoriesCompanion.insert(name: 'Transporte', type: 'expense'),
  CategoriesCompanion.insert(name: 'Moradia', type: 'expense'),
  CategoriesCompanion.insert(name: 'Saúde', type: 'expense'),
  CategoriesCompanion.insert(name: 'Educação', type: 'expense'),
  CategoriesCompanion.insert(name: 'Lazer', type: 'expense'),
  CategoriesCompanion.insert(name: 'Compras', type: 'expense'),
  CategoriesCompanion.insert(name: 'Outros (despesa)', type: 'expense'),
];

/// Call once at startup to ensure default categories exist.
Future<void> seedCategoriesIfEmpty(AppDatabase db) async {
  final list = await db.getAllCategories();
  if (list.isEmpty) {
    for (final c in defaultCategories) {
      await db.insertCategory(c);
    }
  }
}
