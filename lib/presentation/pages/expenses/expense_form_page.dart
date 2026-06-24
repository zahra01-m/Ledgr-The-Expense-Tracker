import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgr/core/utils/currency_provider.dart';
import 'package:ledgr/core/utils/date_formatter.dart';
import 'package:ledgr/domain/entities/expense_entity.dart';
import '../../controllers/expense_controller.dart';
import '../../widgets/animations.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  final ExpenseEntity? initialExpense;

  const ExpenseFormPage({super.key, this.initialExpense});

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  late ExpenseCategory _category;
  late DateTime _date;
  late bool _isRecurring;
  late RecurrenceFrequency _frequency;
  bool _isSaving = false;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    _titleCtrl = TextEditingController(text: expense?.title);
    _amountCtrl = TextEditingController(text: expense?.amount.toString());
    _noteCtrl = TextEditingController(text: expense?.note);
    _category = expense?.category ?? ExpenseCategory.other;
    _date = expense?.date ?? DateTime.now();
    _isRecurring = expense?.isRecurring ?? false;
    _frequency = expense?.frequency ?? RecurrenceFrequency.none;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<bool> _confirmUpdate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Transaction'),
        content: const Text('Save changes to this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final confirmed = await _confirmUpdate();
      if (!confirmed) return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);
    
    try {
      final controller = ref.read(expenseControllerProvider.notifier);
      final amount = double.parse(_amountCtrl.text);
      final title = _titleCtrl.text;
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text;

      // Trigger the operation without 'await'ing it before the pop
      if (_isEditing) {
        controller.updateExpense(
          widget.initialExpense!.copyWith(
            title: title,
            amount: amount,
            category: _category,
            date: _date,
            note: note,
            isRecurring: _isRecurring,
            frequency: _frequency,
          ),
        );
      } else {
        controller.addExpense(
          title: title,
          amount: amount,
          category: _category,
          date: _date,
          note: note,
          isRecurring: _isRecurring,
          frequency: _frequency,
        );
      }
      
      // Return to home screen immediately
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'What did you spend on?',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'How much?',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        currency.symbol,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Amount is required';
                    final parsed = double.tryParse(v);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid positive amount';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Category
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _SectionLabel(label: 'Select Category', theme: theme),
              ),
              const SizedBox(height: 12),
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ExpenseCategory.values.map((cat) {
                    final selected = _category == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              cat.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // Date
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: _SectionLabel(label: 'Transaction Date', theme: theme),
              ),
              const SizedBox(height: 12),
              FadeInSlide(
                delay: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(DateFormatter.formatDate(_date),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Note
              FadeInSlide(
                delay: const Duration(milliseconds: 700),
                child: TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Add a note (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Recurring Options
              FadeInSlide(
                delay: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'Recurrence', theme: theme),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Recurring Transaction'),
                      subtitle: const Text('Automatically repeat this expense'),
                      value: _isRecurring,
                      onChanged: (v) => setState(() {
                        _isRecurring = v;
                        if (!v) {
                          _frequency = RecurrenceFrequency.none;
                        } else if (_frequency == RecurrenceFrequency.none) {
                          _frequency = RecurrenceFrequency.monthly;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    if (_isRecurring)
                      DropdownButtonFormField<RecurrenceFrequency>(
                        initialValue: _frequency,
                        items: RecurrenceFrequency.values
                            .where((f) => f != RecurrenceFrequency.none)
                            .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.displayName),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _frequency = v!),
                        decoration: const InputDecoration(labelText: 'Repeat Frequency'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Save button
              FadeInSlide(
                delay: const Duration(milliseconds: 900),
                direction: const Offset(0, 0.5),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}
