import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_appp/domain/data/model/intensity_level.dart';
import 'package:my_appp/domain/data/model/mood_entry.dart';
import 'package:my_appp/domain/data/model/reflection_flag.dart';
import 'package:my_appp/ui/mood_mirror/bloc/mood_mirror_bloc.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({required this.entry, super.key});

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    timeFormat.format(entry.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    context.read<MoodMirrorBloc>().add(
                          DeleteEntry(id: entry.id),
                        );
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.note,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('${entry.mood.displayName}'),
                  avatar: const Icon(Icons.mood, size: 16),
                ),
                Chip(
                  label: Text('${entry.context.displayName}'),
                  avatar: const Icon(Icons.place, size: 16),
                ),
                Chip(
                  label: Text('Energy: ${entry.energyLevel}'),
                  avatar: const Icon(Icons.bolt, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Derived Analysis',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    '${entry.derivedWeather.emoji} ${entry.derivedWeather.displayName}',
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                Chip(
                  label: Text('Intensity: ${entry.derivedIntensity.displayName}'),
                  backgroundColor: _getIntensityColor(context),
                ),
                Chip(
                  label: Text(entry.derivedReflection.displayName),
                  backgroundColor: _getReflectionColor(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (entry.derivedIntensity) {
      case IntensityLevel.low:
        return theme.colorScheme.secondaryContainer;
      case IntensityLevel.medium:
        return theme.colorScheme.tertiaryContainer;
      case IntensityLevel.high:
        return theme.colorScheme.errorContainer;
    }
  }

  Color _getReflectionColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (entry.derivedReflection) {
      case ReflectionFlag.stable:
        return theme.colorScheme.primaryContainer;
      case ReflectionFlag.recovering:
        return theme.colorScheme.tertiaryContainer;
      case ReflectionFlag.mixed:
      case ReflectionFlag.overloaded:
        return theme.colorScheme.errorContainer;
      case ReflectionFlag.unclear:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }
}
