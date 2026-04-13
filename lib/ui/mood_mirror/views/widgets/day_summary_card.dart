import 'package:flutter/material.dart';
import 'package:my_appp/domain/data/model/day_summary.dart';

class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({required this.summary, super.key});

  final DaySummary? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (summary == null || summary!.totalEntries == 0) {
      return Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.insights,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: 8),
              Text(
                'No entries yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start logging your moments to see insights',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final sum = summary!;

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Day Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              sum.derivedSentence,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildStat(
                  context,
                  'Total Entries',
                  sum.totalEntries.toString(),
                ),
                _buildStat(
                  context,
                  'Avg Energy',
                  sum.averageEnergy.toStringAsFixed(1),
                ),
                if (sum.mostFrequentWeather != null)
                  _buildStat(
                    context,
                    'Top Weather',
                    '${sum.mostFrequentWeather!.emoji} ${sum.mostFrequentWeather!.displayName}',
                  ),
                if (sum.mostCommonContext != null)
                  _buildStat(
                    context,
                    'Main Context',
                    sum.mostCommonContext!.displayName,
                  ),
                _buildStat(
                  context,
                  'High Intensity',
                  sum.highIntensityCount.toString(),
                ),
                _buildStat(
                  context,
                  'Contradictory',
                  sum.contradictoryCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
