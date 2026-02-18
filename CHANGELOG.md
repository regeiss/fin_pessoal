# Changelog

All notable changes to **Fin Pessoal** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

**Convention:** When you make any notable change to the project (features, fixes, dependencies, theme, or structure), update this file in the same change set. Add new entries under the appropriate version and section (Added / Changed / Fixed).

---

## [0.1.0] – 2025-02-16

### Added

- **Onboarding**
  - Multi-screen onboarding (4 screens) shown on first launch.
  - Screens: Controle suas finanças, Orçamentos e metas, Relatórios e insights, Tudo na palma da mão.
  - "Pular" and "Próximo" / "Começar" actions; completion persisted via SharedPreferences so onboarding is not shown again.
  - **Configurações:** switch "Redefinir onboarding" na seção Geral para exibir a tela de boas-vindas novamente ao reabrir o app.

- **Navigation & shell**
  - **Bottom bar (mobile):** 4 main tabs (Início, Transações, Orçamentos, Contas) + "Mais" that opens a list of extra features.
  - **Sidebar (tablet/desktop):** All sections as rail items: Início, Transações, Orçamentos, Contas, Cartões, Empréstimos, Contas fixas, Metas, Relatórios, Insights, IA financeira, Configurações.
  - **More page:** Entry point to Cartões, Empréstimos, Contas fixas, Metas, Relatórios, Insights, IA financeira, Ajuda, Configurações (used from bottom "Mais" on mobile).

- **Help system**
  - **Central de Ajuda:** in-app help with topic list and full-text search. Topics: Primeiros passos, Transações, Orçamentos, Contas, Cartões, Empréstimos, Contas fixas, Metas, Relatórios, Insights, IA financeira, Configurações, Perguntas frequentes (FAQ). All content in PT-BR.
  - **Help data** (`lib/core/help/help_data.dart`): `HelpTopic`, `HelpSection`, and `HelpData` with search and grouping.
  - **Help pages:** `HelpPage` (list + search) and `HelpTopicPage` (topic detail with sections). Access from Mais → Ajuda and Configurações → Central de Ajuda.

- **Home page**
  - **Dashboard:** At the top, a **Receitas x Despesas (últimos 6 meses)** bar chart (fl_chart); then Saldo total, Receitas do mês, Despesas do mês, Resultado do mês (income − expense) with semantic colors.
  - **Quick actions:** Horizontal chips for Nova transação, Nova conta, Transações, Orçamentos, Relatórios (each navigates to the corresponding screen).
  - Existing Contas list and Últimas transações section kept.

- **Reports and graphics**
  - Full reports page with real data and charts (period selector, summary cards, bar chart, pie chart).
  - **Period selector:** Este mês, Últimos 3/6/12 meses (segmented button).
  - **Summary cards:** Receitas, Despesas, Saldo for the selected period (theme semantic colors).
  - **Bar chart (fl_chart):** Receitas x Despesas por mês – grouped bars per month (income up, expense down), y-axis in R\$, month labels MM/yy.
  - **Pie chart:** Despesas por categoria with percentage and legend (category name + %); empty state when no expenses.
  - **Report helpers** (`lib/core/utils/report_utils.dart`): `transactionsInRange`, `totalIncome` / `totalExpense`, `incomeExpenseByMonth`, `expenseByCategory`, `monthsInRange`.
  - Pull-to-refresh to reload transactions and categories.
  - **Dependency:** `fl_chart` (^0.69.0) for charts.
  - Accessible from sidebar and from More on mobile.

- **Insights**
  - Insights page with placeholder cards: Resumo do mês, Gastos por categoria, Dicas de economia.
  - "Em breve" note that insights will use transactions, budgets, and goals data.
  - Accessible from sidebar and More.

- **Financial AI**
  - "Assistente financeiro" page with chat-style UI: message list and text field.
  - Welcome message and placeholder reply indicating future AI integration.
  - Accessible from sidebar and More.

- **Settings**
  - **Configurações** screen with:
    - **Aparência:** Tema (Sistema / Claro / Escuro) with bottom sheet picker; choice persisted via SharedPreferences.
    - **Notificações:** Master "Notificações" switch; "Lembrete de contas fixas" and "Lembrete de metas" (shown only when notifications are on). All toggles persisted.
    - **Geral:** Moeda (Real BRL), placeholder for future currency change.
    - **Sobre:** App name and version (0.1.0).
  - Accessible from sidebar and More.

- **Theme**
  - **App theme** (`lib/core/theme/app_theme.dart`): Dedicated light and dark themes for a financial app.
    - Light: deep blue primary (#0D47A1), teal secondary (#00695C), surface (#E2E8F0), surfaceContainerHighest (#CBD5E1), white cards, consistent AppBar and input styles. `scaffoldBackgroundColor` set for app-wide background.
    - Dark: light blue primary, light teal secondary, surface (#05080B), surfaceContainerHighest (#151B23). `scaffoldBackgroundColor` set for app-wide background.
    - Semantic helpers: `AppTheme.positiveColor(context)` and `AppTheme.negativeColor(context)` for income/expense (green/red) in both themes.
  - Home dashboard and transaction amounts use these semantic colors.

- **Providers & persistence**
  - `themeModeProvider`: Async notifier for theme mode (light/dark/system), persisted with SharedPreferences.
  - `onboardingCompletedProvider`: Async notifier for onboarding completion flag, persisted with SharedPreferences.
  - `notificationPreferencesProvider`: Async notifier for notification settings (enabled, bills reminder, goals reminder), persisted with SharedPreferences.

- **App icon**
  - Personalized launcher icon for Fin Pessoal (financial app style: coin/growth motif, deep blue and teal). Source: `assets/icon/app_icon.png`. `flutter_launcher_icons` configured to generate Android and iOS icons; run `dart run flutter_launcher_icons` after `flutter pub get`. Adaptive icon on Android uses primary color (#0D47A1) as background.

- **Dependencies**
  - `shared_preferences` for persisting theme, onboarding, and notification settings.
  - `fl_chart` for reports bar and pie charts.
  - **Dev:** `flutter_launcher_icons` (^0.14.3) for generating launcher icons from a single image.

### Changed

- **Navigation**
  - Tab bar reduced from 8 items to 4 + "Mais" on mobile to avoid crowding.
  - Sidebar shows all 12 destinations (no "Mais" on rail); mobile uses "Mais" for the same set of features.

- **App entry**
  - `MaterialApp` home is conditional: shows onboarding when not completed, otherwise `MainShell`. Loading/error states show splash or onboarding.

### Fixed

- **Transaction form**
  - Replaced deprecated `value` with `initialValue` in `DropdownButtonFormField` widgets (accounts, categories, credit card) to fix deprecation introduced after Flutter v3.33.0.

- **Loan payment form**
  - Resolved `'Column' isn't a function` error caused by Drift’s `Column` type shadowing Flutter’s layout `Column`. Fix: `import 'package:drift/drift.dart' hide Column;` in `loan_payment_form_page.dart`.

---

## Project structure (overview)

- **`lib/app.dart`** – MaterialApp, theme mode, onboarding vs main home.
- **`lib/main.dart`** – Entry point, DB init, category seeding, ProviderScope.
- **`lib/core/`** – Theme (`app_theme.dart`), providers (settings, onboarding, notifications, accounts, transactions, etc.), constants, utils.
- **`lib/data/`** – Database (Drift), seed data.
- **`lib/presentation/`** – Shell (main_shell.dart), home, transactions, accounts, budgets, credit cards, loans, bills, goals, reports, insights, financial_ai, more, settings, onboarding, and form pages for each feature.

---

[0.1.0]: https://github.com/your-username/fin_pessoal/releases/tag/v0.1.0
