import 'package:flutter/material.dart';

import 'package:my_appp/domain/data/model/expense_model.dart';
import 'package:my_appp/domain/data/model/split_type.dart';

/// Card displaying an individual expense with expandable split details
class ExpenseCard extends StatefulWidget {
  const ExpenseCard({
    required this.expense,
    required this.onDelete,
    super.key,
  });

  final ExpenseModel expense;
  final VoidCallback onDelete;

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expense.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.expense.formattedDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.expense.formattedAmount,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSplitTypeBadge(context),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: widget.expense.paidBy.avatarColor,
                    child: Text(
                      widget.expense.paidBy.initials,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Paid by ${widget.expense.paidBy.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete expense',
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 24),
                Text(
                  'Split Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.expense.splits.map(
                  (split) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            split.userName,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '₹${split.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getBadgeColor() {
      switch (widget.expense.splitType) {
        case SplitType.equal:
          return colorScheme.tertiaryContainer;
        case SplitType.percentage:
          return colorScheme.secondaryContainer;
        case SplitType.weightage:
          return colorScheme.primaryContainer;
      }
    }

    Color getTextColor() {
      switch (widget.expense.splitType) {
        case SplitType.equal:
          return colorScheme.onTertiaryContainer;
        case SplitType.percentage:
          return colorScheme.onSecondaryContainer;
        case SplitType.weightage:
          return colorScheme.onPrimaryContainer;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getBadgeColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.expense.splitType.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
