import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_appp/domain/data/model/transaction_model.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_bloc.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_event.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_state.dart';

/// Tab showing simplified settlement transactions
class SettlementsTab extends StatelessWidget {
  const SettlementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplitWiseBloc, SplitWiseState>(
      builder: (context, state) {
        if (state is! SplitWiseLoaded) {
          return const SizedBox.shrink();
        }

        if (state.expenses.isEmpty) {
          return _buildEmptyState(
            context,
            'No expenses yet',
            'Add expenses to see settlement suggestions',
          );
        }

        if (state.simplifiedTransactions.isEmpty) {
          return _buildSettledState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.simplifiedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = state.simplifiedTransactions[index];
            return _buildTransactionCard(context, transaction);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettledState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All Settled Up!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Everyone has been paid back. No outstanding balances!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: transaction.isSettled ? 0 : 2,
      color: transaction.isSettled
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: transaction.isSettled
              ? colorScheme.outline.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: transaction.isSettled
                            ? colorScheme.outline
                            : colorScheme.errorContainer,
                        child: Text(
                          transaction.fromUserName[0].toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: transaction.isSettled
                                ? Colors.white
                                : colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transaction.fromUserName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: transaction.isSettled
                            ? colorScheme.outline
                            : colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: transaction.isSettled
                              ? colorScheme.surfaceContainerHigh
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transaction.formattedAmount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: transaction.isSettled
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: transaction.isSettled
                            ? colorScheme.outline
                            : colorScheme.primaryContainer,
                        child: Text(
                          transaction.toUserName[0].toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: transaction.isSettled
                                ? Colors.white
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transaction.toUserName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!transaction.isSettled) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _showSettleConfirmation(context, transaction.id),
                icon: const Icon(Icons.check),
                label: const Text('Mark as Settled'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Settled',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettleConfirmation(BuildContext context, String transactionId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as Settled?'),
        content: const Text(
          'Are you sure this payment has been completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SplitWiseBloc>().add(
                    SettleTransaction(transactionId: transactionId),
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
