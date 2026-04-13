import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/filter_options.dart';
import 'package:my_appp/domain/data/model/filter_type.dart';
import 'package:my_appp/ui/mood_mirror/bloc/mood_mirror_bloc.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoodMirrorBloc, MoodMirrorState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (state.currentFilter.filterType != FilterType.all)
                      TextButton.icon(
                        onPressed: () {
                          context.read<MoodMirrorBloc>().add(
                                const ClearFilter(),
                              );
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: state.currentFilter.filterType == FilterType.all,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<MoodMirrorBloc>().add(
                                const ClearFilter(),
                              );
                        }
                      },
                    ),
                    FilterChip(
                      label: const Text('High Intensity'),
                      selected: state.currentFilter.filterType ==
                          FilterType.highIntensity,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<MoodMirrorBloc>().add(
                                const ApplyFilter(
                                  filterOptions: FilterOptions(
                                    filterType: FilterType.highIntensity,
                                  ),
                                ),
                              );
                        }
                      },
                    ),
                    FilterChip(
                      label: const Text('Mixed/Contradictory'),
                      selected: state.currentFilter.filterType ==
                          FilterType.contradictory,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<MoodMirrorBloc>().add(
                                const ApplyFilter(
                                  filterOptions: FilterOptions(
                                    filterType: FilterType.contradictory,
                                  ),
                                ),
                              );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ContextType?>(
                  value: state.currentFilter.selectedContext,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Context',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<ContextType?>(
                      value: null,
                      child: Text('All Contexts'),
                    ),
                    ...ContextType.values.map((context) {
                      return DropdownMenuItem<ContextType?>(
                        value: context,
                        child: Text(context.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      context.read<MoodMirrorBloc>().add(
                            const ClearFilter(),
                          );
                    } else {
                      context.read<MoodMirrorBloc>().add(
                            ApplyFilter(
                              filterOptions: FilterOptions(
                                filterType: FilterType.byContext,
                                selectedContext: value,
                              ),
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
