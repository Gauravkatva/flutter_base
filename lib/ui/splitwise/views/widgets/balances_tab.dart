import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_appp/domain/data/model/split_user.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_bloc.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_state.dart';

/// Tab showing net balances for each user
class BalancesTab extends StatelessWidget {
  const BalancesTab({super.key});

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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];
            final balance = state.netBalances[user.id] ?? 0;

            return _buildBalanceCard(context, user, balance);
          },
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
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No balances yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add expenses to see balances',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    SplitUser user,
    double balance,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isSettled = balance.abs() < 0.01;
    final owes = balance < 0;

    Color getBackgroundColor() {
      if (isSettled) return colorScheme.surfaceContainerHighest;
      if (owes) return colorScheme.errorContainer.withOpacity(0.3);
      return colorScheme.primaryContainer.withOpacity(0.5);
    }

    IconData getIcon() {
      if (isSettled) return Icons.check_circle_outline;
      if (owes) return Icons.arrow_upward;
      return Icons.arrow_downward;
    }

    Color getIconColor() {
      if (isSettled) return colorScheme.tertiary;
      if (owes) return colorScheme.error;
      return colorScheme.primary;
    }

    String getStatusText() {
      if (isSettled) return 'Settled up';
      if (owes) return 'Owes';
      return 'Gets back';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: user.avatarColor,
              child: Text(
                user.initials,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        getIcon(),
                        size: 16,
                        color: getIconColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getStatusText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: getIconColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isSettled)
              Text(
                '₹${balance.abs().toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getIconColor(),
                ),
              )
            else
              Icon(
                Icons.check_circle,
                color: getIconColor(),
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
