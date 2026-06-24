import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../controllers/expense_controller.dart';
import '../../widgets/animations.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseControllerProvider);
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: expensesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('Add transactions to see insights.'));
          }

          final controller = ref.read(expenseControllerProvider.notifier);
          final byCategory = controller.expensesByCategory;
          final total = controller.totalExpenses;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: _SectionHeader(title: 'Spending Distribution', theme: theme),
              ),
              const SizedBox(height: 32),
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth * 0.8;
                    return Center(
                      child: SizedBox(
                        height: size < 300 ? size : 300,
                        width: size < 300 ? size : 300,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: byCategory.entries.map((entry) {
                              final percentage = (entry.value / total) * 100;
                              return PieChartSectionData(
                                color: _colorFor(entry.key),
                                value: entry.value,
                                title: percentage > 8 ? '${percentage.toStringAsFixed(0)}%' : '',
                                radius: 70,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _CategoryLegend(byCategory: byCategory),
              ),
              const SizedBox(height: 48),
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: _SectionHeader(title: 'Category Details', theme: theme),
              ),
              const SizedBox(height: 20),
              StaggeredList(
                delayIncrement: const Duration(milliseconds: 50),
                children: byCategory.entries.map((entry) => _CategoryListTile(
                  category: entry.key,
                  amount: entry.value,
                  percentage: (entry.value / total) * 100,
                  currencySymbol: currency.symbol,
                )).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _colorFor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:          return const Color(0xFFFF9E0B); // Primary Orange
      case ExpenseCategory.transport:     return const Color(0xFF1CB5AC); // Teal
      case ExpenseCategory.entertainment: return const Color(0xFFFFC06A); // Soft Orange
      case ExpenseCategory.shopping:      return const Color(0xFF26C6DA); // Aqua
      case ExpenseCategory.health:        return const Color(0xFF66BB6A); // Green
      case ExpenseCategory.utilities:     return const Color(0xFFFFEE58); // Yellow
      case ExpenseCategory.other:         return const Color(0xFFB0BEC5); // Grey
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final Map<ExpenseCategory, double> byCategory;
  const _CategoryLegend({required this.byCategory});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: byCategory.keys.map((cat) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _colorFor(cat),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(cat.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      )).toList(),
    );
  }

  Color _colorFor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:          return const Color(0xFFFF9E0B);
      case ExpenseCategory.transport:     return const Color(0xFF1CB5AC);
      case ExpenseCategory.entertainment: return const Color(0xFFFFC06A);
      case ExpenseCategory.shopping:      return const Color(0xFF26C6DA);
      case ExpenseCategory.health:        return const Color(0xFF66BB6A);
      case ExpenseCategory.utilities:     return const Color(0xFFFFEE58);
      case ExpenseCategory.other:         return const Color(0xFFB0BEC5);
    }
  }
}

class _CategoryListTile extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final double percentage;
  final String currencySymbol;

  const _CategoryListTile({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(category.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total spend',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormatter.formatAmount(amount, currencySymbol),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
