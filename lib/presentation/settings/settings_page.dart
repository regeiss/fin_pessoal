import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/onboarding_provider.dart';
import 'package:fin_pessoal/core/providers/settings_provider.dart';
import 'package:fin_pessoal/presentation/help/help_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const String appVersion = '0.1.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SectionHeader(title: 'Aparência'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema'),
            subtitle: themeModeAsync.when(
              data: (mode) => Text(_themeModeLabel(mode)),
              loading: () => const Text('Sistema'),
              error: (_, __) => const Text('Sistema'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref),
          ),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Notificações'),
          const _NotificationSettings(),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Geral'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Moeda'),
            subtitle: const Text('Real (BRL)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alteração de moeda em breve.')),
              );
            },
          ),
          const Divider(height: 1),
          _ResetOnboardingTile(),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Ajuda'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Central de Ajuda'),
            subtitle: const Text('Tópicos, busca e perguntas frequentes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HelpPage(),
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Sobre'),
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            title: const Text('Fin Pessoal'),
            subtitle: Text('Versão $appVersion'),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Escuro',
      ThemeMode.system => 'Sistema',
    };
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.read(themeModeProvider);
    final current = themeModeAsync.valueOrNull ?? ThemeMode.system;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tema',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              subtitle: const Text('Segue o tema do dispositivo'),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (v) => _setTheme(context, ref, v),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (v) => _setTheme(context, ref, v),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Escuro'),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (v) => _setTheme(context, ref, v),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _setTheme(BuildContext context, WidgetRef ref, ThemeMode? mode) async {
    if (mode == null) return;
    await ref.read(themeModeProvider.notifier).setTheme(mode);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _ResetOnboardingTile extends ConsumerStatefulWidget {
  const _ResetOnboardingTile();

  @override
  ConsumerState<_ResetOnboardingTile> createState() => _ResetOnboardingTileState();
}

class _ResetOnboardingTileState extends ConsumerState<_ResetOnboardingTile> {
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.replay_outlined),
      title: const Text('Redefinir onboarding'),
      subtitle: const Text('Ver a tela de boas-vindas novamente ao abrir o app'),
      value: _switchValue,
      onChanged: (value) async {
        if (!value) return;
        setState(() => _switchValue = true);
        await ref.read(onboardingCompletedProvider.notifier).reset();
        if (context.mounted) {
          setState(() => _switchValue = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Onboarding redefinido. Feche e abra o app para ver a tela de boas-vindas.'),
            ),
          );
        }
      },
    );
  }
}

class _NotificationSettings extends ConsumerWidget {
  const _NotificationSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    return prefsAsync.when(
      data: (prefs) => Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notificações'),
            subtitle: const Text('Ativar lembretes e avisos'),
            value: prefs.enabled,
            onChanged: (value) => ref.read(notificationPreferencesProvider.notifier).setEnabled(value),
          ),
          if (prefs.enabled) ...[
            SwitchListTile(
              secondary: const Icon(Icons.receipt_long_outlined),
              title: const Text('Lembrete de contas fixas'),
              subtitle: const Text('Avisar quando contas estiverem próximas do vencimento'),
              value: prefs.billsReminder,
              onChanged: (value) =>
                  ref.read(notificationPreferencesProvider.notifier).setBillsReminder(value),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.flag_outlined),
              title: const Text('Lembrete de metas'),
              subtitle: const Text('Avisos de progresso e prazo das metas'),
              value: prefs.goalsReminder,
              onChanged: (value) =>
                  ref.read(notificationPreferencesProvider.notifier).setGoalsReminder(value),
            ),
          ],
          const Divider(height: 1),
        ],
      ),
      loading: () => const ListTile(
        leading: Icon(Icons.notifications_outlined),
        title: Text('Notificações'),
        trailing: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Notificações'),
        subtitle: Text('Erro ao carregar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
