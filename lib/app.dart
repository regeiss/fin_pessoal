import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fin_pessoal/core/providers/onboarding_provider.dart';
import 'package:fin_pessoal/core/providers/settings_provider.dart';
import 'package:fin_pessoal/core/theme/app_theme.dart';
import 'package:fin_pessoal/presentation/onboarding/onboarding_page.dart';
import 'package:fin_pessoal/presentation/shell/main_shell.dart';

class FinPessoalApp extends ConsumerWidget {
  const FinPessoalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final onboardingComplete = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'Fin Pessoal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: onboardingComplete.when(
        data: (completed) => completed ? const MainShell() : const OnboardingPage(),
        loading: () => const _OnboardingSplash(),
        error: (_, __) => const OnboardingPage(),
      ),
    );
  }
}

class _OnboardingSplash extends StatelessWidget {
  const _OnboardingSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
