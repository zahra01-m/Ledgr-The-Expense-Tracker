import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

import '../../../core/utils/currency_provider.dart';
import '../../../data/services/export_service.dart';
import '../../controllers/expense_controller.dart';
import '../../widgets/animations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FadeInSlide(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInSlide(
            delay: const Duration(milliseconds: 200),
            child: Card(
              child: Column(
                children: [
                  _ThemeOptionTile(
                    label: 'Light',
                    icon: Icons.light_mode_outlined,
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ThemeOptionTile(
                    label: 'Dark',
                    icon: Icons.dark_mode_outlined,
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ThemeOptionTile(
                    label: 'System default',
                    icon: Icons.settings_suggest_outlined,
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInSlide(
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Localization',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInSlide(
            delay: const Duration(milliseconds: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.currency_exchange_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: const Text(
                        'Currency',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownButton<Currency>(
                      value: ref.watch(currencyProvider),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onChanged: (v) => ref.read(currencyProvider.notifier).setCurrency(v!),
                      items: supportedCurrencies
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  '${c.name} (${c.symbol})',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInSlide(
            delay: const Duration(milliseconds: 500),
            child: Text(
              'Export Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInSlide(
            delay: const Duration(milliseconds: 600),
            child: Card(
              child: ListTile(
                leading: const _FeatureIcon(icon: Icons.ios_share_rounded, color: Colors.purple),
                title: const Text('Export to CSV', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Share your transaction history'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  final expenses = ref.read(expenseControllerProvider).value ?? [];
                  if (expenses.isNotEmpty) {
                    ExportService.exportToCsv(expenses);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No expenses to export')),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _FeatureIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;

    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: (mode) => mode != null ? onChanged(mode) : null,
      activeColor: theme.colorScheme.primary,
      title: Row(
        children: [
          Icon(icon, size: 22, color: selected ? theme.colorScheme.primary : Colors.grey),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          )),
        ],
      ),
    );
  }
}
