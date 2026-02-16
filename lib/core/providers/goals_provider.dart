import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(databaseProvider).watchAllGoals();
});

final goalsFutureProvider = FutureProvider<List<Goal>>((ref) {
  return ref.watch(databaseProvider).getAllGoals();
});

final addGoalProvider = Provider<void Function(GoalsCompanion)>((ref) {
  return (entry) => ref.read(databaseProvider).insertGoal(entry);
});

final updateGoalProvider = Provider<void Function(Goal)>((ref) {
  return (goal) => ref.read(databaseProvider).updateGoal(goal);
});

final deleteGoalProvider = Provider<void Function(Goal)>((ref) {
  return (goal) => ref.read(databaseProvider).deleteGoal(goal);
});
