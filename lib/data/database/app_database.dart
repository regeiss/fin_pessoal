import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('bank'))(); // bank, cash, savings
  RealColumn get initialBalance => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('BRL'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // income | expense
  TextColumn get iconName => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class CreditCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get lastFourDigits => text().nullable()();
  RealColumn get creditLimit => real()();
  IntColumn get closingDay => integer()(); // 1-31
  IntColumn get dueDay => integer()(); // 1-31
  IntColumn get accountId => integer().nullable().references(Accounts, #id)(); // account used to pay the bill
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()(); // monthly limit
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // owed | lent
  RealColumn get principal => real()();
  RealColumn get interestRate => real().nullable()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get dueDay => integer().nullable()(); // 1-31
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class LoanPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get loanId => integer().references(Loans, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  IntColumn get dueDay => integer()(); // 1-31
  TextColumn get frequency => text().withDefault(const Constant('monthly'))(); // monthly | yearly
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get type => text()(); // income | expense
  IntColumn get creditCardId => integer().nullable().references(CreditCards, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Accounts, Categories, CreditCards, Budgets, Loans, LoanPayments, Bills, Goals, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(creditCards);
            await migrator.addColumn(transactions, transactions.creditCardId);
          }
          if (from < 3) {
            await migrator.createTable(budgets);
          }
          if (from < 4) {
            await migrator.createTable(loans);
            await migrator.createTable(loanPayments);
            await migrator.createTable(bills);
            await migrator.createTable(goals);
          }
        },
      );

  // --- Accounts
  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
  Future<Account?> getAccountById(int id) => (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();
  Future<int> insertAccount(AccountsCompanion entry) => into(accounts).insert(entry);
  Future<bool> updateAccount(Account entry) => update(accounts).replace(entry);
  Future<int> deleteAccount(Account entry) => delete(accounts).delete(entry);

  // --- Categories
  Future<List<Category>> getAllCategories() => select(categories).get();
  Future<List<Category>> getCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).get();
  Stream<List<Category>> watchCategories() => select(categories).watch();
  Future<Category?> getCategoryById(int id) => (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);
  Future<bool> updateCategory(Category entry) => update(categories).replace(entry);
  Future<int> deleteCategory(Category entry) => delete(categories).delete(entry);

  // --- Credit Cards
  Future<List<CreditCard>> getAllCreditCards() => select(creditCards).get();
  Stream<List<CreditCard>> watchAllCreditCards() => select(creditCards).watch();
  Future<CreditCard?> getCreditCardById(int id) =>
      (select(creditCards)..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<int> insertCreditCard(CreditCardsCompanion entry) => into(creditCards).insert(entry);
  Future<bool> updateCreditCard(CreditCard entry) => update(creditCards).replace(entry);
  Future<int> deleteCreditCard(CreditCard entry) => delete(creditCards).delete(entry);

  // --- Budgets
  Future<List<Budget>> getAllBudgets() => select(budgets).get();
  Stream<List<Budget>> watchAllBudgets() => select(budgets).watch();
  Future<Budget?> getBudgetByCategoryId(int categoryId) =>
      (select(budgets)..where((b) => b.categoryId.equals(categoryId))).getSingleOrNull();
  Future<int> insertBudget(BudgetsCompanion entry) => into(budgets).insert(entry);
  Future<bool> updateBudget(Budget entry) => update(budgets).replace(entry);
  Future<int> deleteBudget(Budget entry) => delete(budgets).delete(entry);

  // --- Loans
  Future<List<Loan>> getAllLoans() => select(loans).get();
  Stream<List<Loan>> watchAllLoans() => select(loans).watch();
  Future<Loan?> getLoanById(int id) => (select(loans)..where((l) => l.id.equals(id))).getSingleOrNull();
  Future<int> insertLoan(LoansCompanion entry) => into(loans).insert(entry);
  Future<bool> updateLoan(Loan entry) => update(loans).replace(entry);
  Future<int> deleteLoan(Loan entry) => delete(loans).delete(entry);

  Future<void> deleteLoanAndPayments(Loan entry) async {
    final payments = await getPaymentsByLoan(entry.id);
    for (final p in payments) await delete(loanPayments).delete(p);
    await delete(loans).delete(entry);
  }

  Future<List<LoanPayment>> getPaymentsByLoan(int loanId) =>
      (select(loanPayments)..where((p) => p.loanId.equals(loanId))..orderBy([(p) => OrderingTerm.desc(p.date)])).get();
  Future<int> insertLoanPayment(LoanPaymentsCompanion entry) => into(loanPayments).insert(entry);
  Future<int> deleteLoanPayment(LoanPayment entry) => delete(loanPayments).delete(entry);

  // --- Bills
  Future<List<Bill>> getAllBills() => select(bills).get();
  Stream<List<Bill>> watchAllBills() => select(bills).watch();
  Future<Bill?> getBillById(int id) => (select(bills)..where((b) => b.id.equals(id))).getSingleOrNull();
  Future<int> insertBill(BillsCompanion entry) => into(bills).insert(entry);
  Future<bool> updateBill(Bill entry) => update(bills).replace(entry);
  Future<int> deleteBill(Bill entry) => delete(bills).delete(entry);

  // --- Goals
  Future<List<Goal>> getAllGoals() => select(goals).get();
  Stream<List<Goal>> watchAllGoals() => select(goals).watch();
  Future<Goal?> getGoalById(int id) => (select(goals)..where((g) => g.id.equals(id))).getSingleOrNull();
  Future<int> insertGoal(GoalsCompanion entry) => into(goals).insert(entry);
  Future<bool> updateGoal(Goal entry) => update(goals).replace(entry);
  Future<int> deleteGoal(Goal entry) => delete(goals).delete(entry);

  // --- Transactions
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();
  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  Future<List<Transaction>> getTransactionsByAccount(int accountId) =>
      (select(transactions)..where((t) => t.accountId.equals(accountId))..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  Future<List<Transaction>> getTransactionsByCreditCard(int creditCardId) =>
      (select(transactions)
            ..where((t) => t.creditCardId.equals(creditCardId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();
  Future<List<Transaction>> getTransactionsInRange(DateTime start, DateTime end) =>
      (select(transactions)
            ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();
  Future<Transaction?> getTransactionById(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTransaction(TransactionsCompanion entry) => into(transactions).insert(entry);
  Future<bool> updateTransaction(Transaction entry) => update(transactions).replace(entry);
  Future<int> deleteTransaction(Transaction entry) => delete(transactions).delete(entry);
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'fin_pessoal.db');
}
