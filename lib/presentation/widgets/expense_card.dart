import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseCard extends ConsumerWidget {
  final ExpenseEntity expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  });

  Color _colorFor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:          return const Color(0xFFA04423); // Primary
      case ExpenseCategory.transport:     return const Color(0xFF7FB4D4); // Secondary
      case ExpenseCategory.entertainment: return const Color(0xFFBB8469); // Tertiary
      case ExpenseCategory.shopping:      return const Color(0xFF743119); // Darker Rust
      case ExpenseCategory.health:        return const Color(0xFF5A8AA8); // Darker Blue
      case ExpenseCategory.utilities:     return const Color(0xFF90624D); // Muted Brown
      case ExpenseCategory.other:         return const Color(0xFF4E261E); // OnSurface Brown
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _colorFor(expense.category);
    final currency = ref.watch(currencyProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  expense.category.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title, category badge, date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  // Using Wrap to prevent overflow on narrow screens
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _CategoryBadge(
                          label: expense.category.displayName, color: color),
                      Text(
                        DateFormatter.formatDate(expense.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount + Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormatter.formatAmount(expense.amount, currency.symbol),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
