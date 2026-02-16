# Fin Pessoal — Personal Finance App — Plan

## 1. Vision & Goals

- **Purpose:** Help users track income, expenses, and savings so they can understand where money goes and reach financial goals.
- **Audience:** Individuals and families who want a simple, local-first finance tracker (no mandatory cloud, optional sync later).
- **Principles:** Clear UI, minimal friction to log transactions, privacy-first (data on device by default).

---

## 2. Core Features

### 2.1 MVP (Phase 1)

| Feature | Description |
|--------|-------------|
| **Accounts** | Wallets/accounts (e.g. “Nubank”, “Carteira”, “Poupança”) with balance. |
| **Categories** | Income and expense categories (Salário, Alimentação, Transporte, etc.) with optional icons/colors. |
| **Transactions** | Add/edit/delete: amount, date, account, category, note. Support income and expense. |
| **Balance** | Per-account balance and simple “total” across accounts. |
| **Summary** | By period (e.g. month): total income, total expenses, balance (income − expenses). |
| **Persistence** | Local storage (e.g. SQLite via `sqflite` or `drift`) so data survives app restarts. |

### 2.2 Phase 2 — Deeper insights

- **Charts:** Spending by category (e.g. pie/bar), income vs expenses over time.
- **Filters:** By account, category, date range.
- **Recurring transactions:** Templates for monthly bills/salary (optional auto-create or reminders).
- **Goals:** Simple savings goals (target amount, current progress).

### 2.3 Phase 3 — Polish & optional extras

- **Multi-currency** (optional) or single-currency with clear display.
- **Export:** CSV/PDF for records.
- **Backup/restore:** Export/import JSON or file-based backup.
- **Themes:** Light/dark and maybe accent color.
- **Optional sync:** Cloud backup or sync (e.g. Firebase or custom backend) — only if needed.

---

## 3. Data Model (conceptual)

- **Account:** id, name, type (e.g. bank, cash), initialBalance, currency, createdAt.
- **Category:** id, name, type (income | expense), icon/color, parentId (optional for subcategories).
- **Transaction:** id, amount, date, accountId, categoryId, note, type (income | expense), createdAt.
- **Balance:** Derived from initialBalance + sum(transactions) per account; no separate table needed for MVP.

*(Exact field names and types can be refined when implementing with SQLite/drift.)*

---

## 4. Architecture (Flutter)

### 4.1 Suggested structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, theme, routes
├── core/
│   ├── theme/
│   ├── constants/
│   └── utils/
├── data/
│   ├── models/                 # Account, Category, Transaction
│   ├── database/               # DB helper, DAOs
│   └── repositories/           # AccountRepo, CategoryRepo, TransactionRepo
├── domain/                     # Optional: use cases / business rules
├── presentation/
│   ├── home/                   # Dashboard (summary, recent transactions)
│   ├── accounts/               # List accounts, add/edit account
│   ├── transactions/           # List by account/period, add/edit transaction
│   ├── categories/             # Manage categories (admin)
│   └── summary/                # Monthly summary, filters
└── widgets/                    # Shared: amount display, date picker, etc.
```

### 4.2 State management

- **Option A (simpler):** `Provider` or `Riverpod` + repositories; DB as single source of truth.
- **Option B:** Add a lightweight layer (e.g. BLoC/Cubit) if you prefer clear separation and testability.

### 4.3 Navigation

- Bottom nav or drawer: **Home**, **Transactions**, **Accounts**, **Summary** (or combine Summary into Home).
- Push routes for: Add/Edit Account, Add/Edit Transaction, Category management, filters.

---

## 5. Tech Stack (suggested)

| Need | Package / approach |
|------|--------------------|
| Local DB | `drift` (recommended) or `sqflite` |
| State | `flutter_riverpod` or `provider` |
| Navigation | `go_router` or Navigator 2.0 / `MaterialApp.routes` |
| Charts (Phase 2) | `fl_chart` or `syncfusion_flutter_charts` (license check) |
| Date/time | `intl` for formatting; built-in `DateTime` |
| Icons | `Material Icons` + maybe `flutter_svg` for custom category icons |

---

## 6. UI/UX Outline

### 6.1 Home (Dashboard)

- Total balance (all accounts).
- Quick summary: “This month: +R$ X income, −R$ Y expenses”.
- List of accounts with current balance.
- Recent transactions (last 5–10) with “See all” → Transactions screen.

### 6.2 Transactions

- List grouped by date (or by account if filtered).
- FAB “+” → Add transaction.
- Tap item → Edit; swipe or long-press → Delete (with confirm).
- Optional: filter chips (account, category, period).

### 6.3 Add/Edit Transaction

- Amount (numeric, with decimal).
- Type: Income / Expense (segmented or dropdown).
- Category selector (list filtered by type).
- Account selector.
- Date picker.
- Optional note (short text).

### 6.4 Accounts

- List of accounts with balance.
- FAB → Add account (name, type, initial balance).
- Tap → Edit; consider “Archive” instead of hard delete if there’s history.

### 6.5 Summary (or part of Home)

- Select month (and optionally year).
- Show: Total income, total expenses, difference.
- Phase 2: Chart by category.

### 6.6 Categories (settings/admin)

- List income and expense categories.
- Add/edit: name, icon, color.
- Pre-seed common categories on first run.

---

## 7. Phases & Roadmap

| Phase | Focus | Deliverables |
|-------|--------|--------------|
| **1. Foundation** | Data + basic UI | DB schema, models, repos; Home + Accounts CRUD + Transactions CRUD; balances and monthly summary on Home. |
| **2. Usability** | Navigation + flows | Bottom nav/drawer; polished Add/Edit Transaction; category management; date filters. |
| **3. Insights** | Charts + goals | Charts (by category, over time); simple goals; recurring templates (optional). |
| **4. Polish** | Export, theme, backup | Export CSV/PDF; theme; backup/restore; optional sync. |

---

## 8. Success Criteria (MVP)

- User can create accounts and categories.
- User can add income and expenses linked to an account and category.
- Balances update correctly per account and in total.
- User can see “this month” income, expenses, and balance.
- Data persists after closing the app.

---

## 9. Next Steps

1. Add dependencies: `drift` (or `sqflite`), `riverpod` (or `provider`), `go_router` (optional).
2. Implement `data/models` and database (tables for Account, Category, Transaction).
3. Implement repositories and inject them (e.g. via Provider/Riverpod).
4. Build **Home** screen with hardcoded or seed data first, then connect to DB.
5. Build **Accounts** list + add/edit screen.
6. Build **Transactions** list + add/edit screen and wire category/account pickers.
7. Implement balance calculation and monthly summary on Home.
8. Add category management and seed default categories on first launch.

You can use this plan as a single source of truth and tick off items as you implement them (e.g. in this file or in GitHub issues).
