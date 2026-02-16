import 'package:fin_pessoal/app.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:fin_pessoal/data/database/seed_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize DB and seed default categories (Riverpod would need runUnsafe to get db here,
  // so we create a one-off instance just for seeding).
  final db = AppDatabase();
  await seedCategoriesIfEmpty(db);
  await db.close();

  runApp(
    const ProviderScope(
      child: FinPessoalApp(),
    ),
  );
}
