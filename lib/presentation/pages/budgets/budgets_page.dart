import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../controllers/budget_controller.dart';
import '../../widgets/animations.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Planner')),
      body: budgetsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Spending Limits',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ),
            const SizedBox(height: 8),
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Monitor your category limits to save more every month.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (budgets.isEmpty)
              const FadeInSlide(
                delay: Duration(milliseconds: 300),
                child: Center(child: Text('No budgets configured yet.')),
              )
            else
              StaggeredList(
                delayIncrement: const Duration(milliseconds: 80),
                children: budgets.map((budget) => _BudgetCard(budget: budget)).toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FadeInSlide(
        delay: const Duration(milliseconds: 600),
        direction: const Offset(0, 1),
        child: FloatingActionButton.extended(
          onPressed: () => _showSetBudgetDialog(context, ref),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Set New Limit'),
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _SetBudgetDialog(),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final dynamic budget; // Using dynamic for simplicity in this draft
  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final percent = (budget.spent / budget.limit).clamp(0.0, 1.0);
    final isOver = budget.spent > budget.limit;
    final currency = ref.watch(currencyProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(budget.category.icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    budget.category.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                  onPressed: () => ProviderScope.containerOf(context)
                      .read(budgetControllerProvider.notifier)
                      .deleteBudget(budget.id),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                color: isOver ? Colors.red.shade400 : theme.colorScheme.primary,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPENT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormatter.formatAmount(budget.spent, currency.symbol),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isOver ? Colors.red : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LIMIT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormatter.formatAmount(budget.limit, currency.symbol),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetBudgetDialog extends ConsumerStatefulWidget {
  const _SetBudgetDialog();

  @override
  ConsumerState<_SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends ConsumerState<_SetBudgetDialog> {
  ExpenseCategory _category = ExpenseCategory.food;
  final _limitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Set Category Limit', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ExpenseCategory>(
            initialValue: _category,
            items: ExpenseCategory.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.displayName)))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _limitCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monthly Limit',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  currency.symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
        ),
        Consumer(
          builder: (ctx, ref, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 48),
            ),
            onPressed: () async {
              final limit = double.tryParse(_limitCtrl.text);
              if (limit != null && limit > 0) {
                await ref.read(budgetControllerProvider.notifier).setBudget(_category, limit);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Set Limit'),
          ),
        ),
      ],
    );
  }
}
