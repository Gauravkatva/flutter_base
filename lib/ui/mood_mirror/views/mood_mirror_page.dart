import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/ui/mood_mirror/bloc/mood_mirror_bloc.dart';
import 'package:my_appp/ui/mood_mirror/views/widgets/day_summary_card.dart';
import 'package:my_appp/ui/mood_mirror/views/widgets/entry_card.dart';
import 'package:my_appp/ui/mood_mirror/views/widgets/entry_form.dart';
import 'package:my_appp/ui/mood_mirror/views/widgets/filter_bar.dart';

class MoodMirrorPage extends StatelessWidget {
  const MoodMirrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoodMirrorBloc(),
      child: const MoodMirrorView(),
    );
  }
}

class MoodMirrorView extends StatelessWidget {
  const MoodMirrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodMirror++'),
        centerTitle: true,
      ),
      body: BlocBuilder<MoodMirrorBloc, MoodMirrorState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Day Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DaySummaryCard(summary: state.daySummary),
                ),
              ),

              // Entry Form
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: EntryForm(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Filter Bar
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: FilterBar(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Entries Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Entries (${state.filteredEntries.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Entries List or Empty State
              if (state.filteredEntries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.entries.isEmpty
                                ? 'No entries yet'
                                : 'No entries match the filter',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.entries.isEmpty
                                ? 'Add your first entry above'
                                : 'Try a different filter',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = state.filteredEntries[index];
                      return EntryCard(entry: entry);
                    },
                    childCount: state.filteredEntries.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
