import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_appp/ui/splitwise/bloc/splitwise_bloc.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_event.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_state.dart';
import 'package:my_appp/ui/splitwise/views/widgets/expense_card.dart';

/// Tab showing list of all expenses
class ExpensesTab extends StatelessWidget {
  const ExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplitWiseBloc, SplitWiseState>(
      builder: (context, state) {
        if (state is! SplitWiseLoaded) {
          return const SizedBox.shrink();
        }

        if (state.expenses.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            _buildSummaryCard(context, state),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.expenses.length,
                itemBuilder: (context, index) {
                  final expense = state.expenses[state.expenses.length - 1 - index];
                  return ExpenseCard(
                    expense: expense,
                    onDelete: () {
                      _showDeleteConfirmation(context, expense.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first expense',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SplitWiseLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            icon: Icons.receipt,
            label: 'Total Expenses',
            value: state.totalExpenses.toString(),
          ),
          Container(
            height: 40,
            width: 1,
            color: colorScheme.outline.withOpacity(0.3),
          ),
          _buildSummaryItem(
            context,
            icon: Icons.currency_rupee,
            label: 'Total Spent',
            value: state.formattedTotalSpent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String expenseId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text(
          'Are you sure you want to delete this expense? '
          'This will recalculate all balances.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SplitWiseBloc>().add(
                    DeleteExpense(expenseId: expenseId),
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
