// import 'package:drift/drift.dart';
import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive list of all categories.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(databaseProvider).watchCategories();
});

/// Categories by type (income or expense) for dropdowns.
final categoriesByTypeProvider = FutureProvider.family<List<Category>, String>((
  ref,
  type,
) {
  return ref.watch(databaseProvider).getCategoriesByType(type);
});

/// Add a new category.
final addCategoryProvider = Provider<void Function(CategoriesCompanion)>((ref) {
  return (entry) {
    ref.read(databaseProvider).insertCategory(entry);
  };
});

/// Update a category.
final updateCategoryProvider = Provider<void Function(Category)>((ref) {
  return (category) {
    ref.read(databaseProvider).updateCategory(category);
  };
});

/// Delete a category.
final deleteCategoryProvider = Provider<void Function(Category)>((ref) {
  return (category) {
    ref.read(databaseProvider).deleteCategory(category);
  };
});
