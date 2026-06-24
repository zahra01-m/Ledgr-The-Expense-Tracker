import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/currency_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../widgets/animations.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/loading_widget.dart';
import '../analytics/analytics_page.dart';
import '../expenses/expense_form_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final expensesAsync = ref.watch(filteredExpensesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.shortName ?? 'there'} 👋',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'My Finances',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _confirmSignOut(context, ref),
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Sign Out',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Search Bar ────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: TextField(
                    onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),

            // ── Summary Card & Chart ──────────────────────────────
            SliverToBoxAdapter(
              child: FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: Consumer(
                  builder: (context, ref, _) {
                    final rawExpenses = ref.watch(expenseControllerProvider);
                    return rawExpenses.maybeWhen(
                      data: (_) => _SummarySection(
                        controller: ref.read(expenseControllerProvider.notifier),
                      ),
                      orElse: () => const SizedBox(),
                    );
                  },
                ),
              ),
            ),

            // ── Category Filters ──────────────────────────────────
            SliverToBoxAdapter(
              child: FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: ref.watch(categoryFilterProvider) == null,
                        onSelected: (_) => ref.read(categoryFilterProvider.notifier).state = null,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      const SizedBox(width: 8),
                      ...ExpenseCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.displayName),
                          selected: ref.watch(categoryFilterProvider) == cat,
                          onSelected: (_) => ref.read(categoryFilterProvider.notifier).state = cat,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section header ────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Row(
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
                      ),
                      const Spacer(),
                      expensesAsync.maybeWhen(
                        data: (expenses) => Text(
                          '${expenses.length} items',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        orElse: () => const SizedBox(),
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<ExpenseSortOption>(
                        tooltip: 'Sort',
                        initialValue: ref.watch(sortOptionProvider),
                        icon: Icon(
                          Icons.sort_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        onSelected: (option) =>
                        ref.read(sortOptionProvider.notifier).state = option,
                        itemBuilder: (context) => ExpenseSortOption.values
                            .map((option) => PopupMenuItem(
                          value: option,
                          child: Text('${option.icon}  ${option.displayName}'),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Expense List ──────────────────────────────────────
            expensesAsync.when(
              loading: () => const SliverFillRemaining(
                child: LoadingWidget(message: 'Syncing expenses...'),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(e.toString(), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              data: (expenses) => expenses.isEmpty
                  ? const SliverFillRemaining(child: _EmptyState())
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                    return FadeInSlide(
                      delay: Duration(milliseconds: 100 * (i < 8 ? i : 8)),
                      child: ExpenseCard(
                        expense: expenses[i],
                        onDelete: () => _confirmDelete(ctx, ref, expenses[i]),
                        onEdit: () => _confirmEdit(ctx, expenses[i]),
                      ),
                    );
                  },
                  childCount: expenses.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButton: FadeInSlide(
        delay: const Duration(milliseconds: 800),
        direction: const Offset(0, 1),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExpenseFormPage()),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Expense'),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      WidgetRef ref,
      ExpenseEntity expense,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${expense.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _confirmEdit(BuildContext context, ExpenseEntity expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: Text('Do you want to edit "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Edit'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExpenseFormPage(initialExpense: expense),
        ),
      );
    }
  }
}

// ─── Summary Section ──────────────────────────────────────────────

class _SummarySection extends ConsumerWidget {
  final ExpenseController controller;
  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final total = controller.totalExpenses;
    final byCategory = controller.expensesByCategory;
    final currency = ref.watch(currencyProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AnalyticsPage()),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL BALANCE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        DateFormatter.formatAmount(total, currency.symbol),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 14),
                      Text(
                        'Detailed breakdown >',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (total > 0)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 110,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 24,
                          sections: byCategory.entries.map((entry) {
                            return PieChartSectionData(
                              color: _colorFor(entry.key),
                              value: entry.value,
                              title: '',
                              radius: 14,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:          return Colors.white;
      case ExpenseCategory.transport:     return const Color(0xFFB2EBF2); // Aqua
      case ExpenseCategory.entertainment: return const Color(0xFFFFCCBC); // Peach
      case ExpenseCategory.shopping:      return const Color(0xFFE1F5FE); // Light Blue
      case ExpenseCategory.health:        return const Color(0xFFC8E6C9); // Mint
      case ExpenseCategory.utilities:     return const Color(0xFFFFF9C4); // Yellow
      case ExpenseCategory.other:         return const Color(0xFFF5F5F5); // Grey
    }
  }
}

// ─── Empty State ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 20),
          Text('No transactions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Tap the + button to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
        ],
      ),
    );
  }
}
