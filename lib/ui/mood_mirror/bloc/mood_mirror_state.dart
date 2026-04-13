part of 'mood_mirror_bloc.dart';

class MoodMirrorState extends Equatable {
  const MoodMirrorState({
    this.entries = const [],
    this.filteredEntries = const [],
    this.daySummary,
    this.currentFilter = const FilterOptions(filterType: FilterType.all),
  });

  final List<MoodEntry> entries;
  final List<MoodEntry> filteredEntries;
  final DaySummary? daySummary;
  final FilterOptions currentFilter;

  @override
  List<Object?> get props => [entries, filteredEntries, daySummary, currentFilter];

  MoodMirrorState copyWith({
    List<MoodEntry>? entries,
    List<MoodEntry>? filteredEntries,
    DaySummary? daySummary,
    FilterOptions? currentFilter,
  }) {
    return MoodMirrorState(
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      daySummary: daySummary ?? this.daySummary,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}
