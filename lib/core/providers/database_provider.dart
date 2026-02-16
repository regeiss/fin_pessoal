import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single instance of the app database. Riverpod keeps it alive for the app lifetime.
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
