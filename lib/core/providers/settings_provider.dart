import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyThemeMode = 'theme_mode';
const _keyNotificationsEnabled = 'notifications_enabled';
const _keyNotificationsBillsReminder = 'notifications_bills_reminder';
const _keyNotificationsGoalsReminder = 'notifications_goals_reminder';

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode);
    return index != null && index >= 0 && index < ThemeMode.values.length
        ? ThemeMode.values[index]
        : ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = AsyncData(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }
}

/// Notification preferences (persisted).
class NotificationPreferences {
  const NotificationPreferences({
    this.enabled = true,
    this.billsReminder = true,
    this.goalsReminder = true,
  });

  final bool enabled;
  final bool billsReminder;
  final bool goalsReminder;

  NotificationPreferences copyWith({
    bool? enabled,
    bool? billsReminder,
    bool? goalsReminder,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      billsReminder: billsReminder ?? this.billsReminder,
      goalsReminder: goalsReminder ?? this.goalsReminder,
    );
  }
}

final notificationPreferencesProvider =
    AsyncNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
        NotificationPreferencesNotifier.new);

class NotificationPreferencesNotifier extends AsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      enabled: prefs.getBool(_keyNotificationsEnabled) ?? true,
      billsReminder: prefs.getBool(_keyNotificationsBillsReminder) ?? true,
      goalsReminder: prefs.getBool(_keyNotificationsGoalsReminder) ?? true,
    );
  }

  Future<void> _save(NotificationPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyNotificationsEnabled, prefs.enabled);
    await sp.setBool(_keyNotificationsBillsReminder, prefs.billsReminder);
    await sp.setBool(_keyNotificationsGoalsReminder, prefs.goalsReminder);
  }

  Future<void> setEnabled(bool value) async {
    final current = state.valueOrNull ?? const NotificationPreferences();
    final next = current.copyWith(enabled: value);
    state = AsyncData(next);
    await _save(next);
  }

  Future<void> setBillsReminder(bool value) async {
    final current = state.valueOrNull ?? const NotificationPreferences();
    final next = current.copyWith(billsReminder: value);
    state = AsyncData(next);
    await _save(next);
  }

  Future<void> setGoalsReminder(bool value) async {
    final current = state.valueOrNull ?? const NotificationPreferences();
    final next = current.copyWith(goalsReminder: value);
    state = AsyncData(next);
    await _save(next);
  }
}
