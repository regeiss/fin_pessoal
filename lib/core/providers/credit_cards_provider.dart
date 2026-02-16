import 'package:fin_pessoal/core/providers/database_provider.dart';
import 'package:fin_pessoal/data/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive list of all credit cards.
final creditCardsStreamProvider = StreamProvider<List<CreditCard>>((ref) {
  return ref.watch(databaseProvider).watchAllCreditCards();
});

/// One-time fetch of all credit cards (e.g. for dropdowns).
final creditCardsFutureProvider = FutureProvider<List<CreditCard>>((ref) {
  return ref.watch(databaseProvider).getAllCreditCards();
});

/// Add a new credit card.
final addCreditCardProvider = Provider<void Function(CreditCardsCompanion)>((ref) {
  return (entry) {
    ref.read(databaseProvider).insertCreditCard(entry);
  };
});

/// Update a credit card.
final updateCreditCardProvider = Provider<void Function(CreditCard)>((ref) {
  return (card) {
    ref.read(databaseProvider).updateCreditCard(card);
  };
});

/// Delete a credit card.
final deleteCreditCardProvider = Provider<void Function(CreditCard)>((ref) {
  return (card) {
    ref.read(databaseProvider).deleteCreditCard(card);
  };
});
