import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/day_summary.dart';
import 'package:my_appp/domain/data/model/filter_options.dart';
import 'package:my_appp/domain/data/model/filter_type.dart';
import 'package:my_appp/domain/data/model/intensity_level.dart';
import 'package:my_appp/domain/data/model/mood_entry.dart';
import 'package:my_appp/domain/data/model/mood_type.dart';
import 'package:my_appp/domain/data/model/reflection_flag.dart';
import 'package:my_appp/ui/mood_mirror/utils/intensity_calculator.dart';
import 'package:my_appp/ui/mood_mirror/utils/reflection_analyzer.dart';
import 'package:my_appp/ui/mood_mirror/utils/summary_generator.dart';
import 'package:my_appp/ui/mood_mirror/utils/text_analyzer.dart';
import 'package:my_appp/ui/mood_mirror/utils/weather_derivation_engine.dart';
import 'package:uuid/uuid.dart';

part 'mood_mirror_event.dart';
part 'mood_mirror_state.dart';

class MoodMirrorBloc extends Bloc<MoodMirrorEvent, MoodMirrorState> {
  MoodMirrorBloc()
      : _textAnalyzer = TextAnalyzer(),
        _weatherEngine = WeatherDerivationEngine(),
        _intensityCalculator = IntensityCalculator(),
        _reflectionAnalyzer = ReflectionAnalyzer(),
        _summaryGenerator = SummaryGenerator(),
        _uuid = const Uuid(),
        super(const MoodMirrorState()) {
    on<AddEntry>(_onAddEntry);
    on<DeleteEntry>(_onDeleteEntry);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilter>(_onClearFilter);
  }

  final TextAnalyzer _textAnalyzer;
  final WeatherDerivationEngine _weatherEngine;
  final IntensityCalculator _intensityCalculator;
  final ReflectionAnalyzer _reflectionAnalyzer;
  final SummaryGenerator _summaryGenerator;
  final Uuid _uuid;

  FutureOr<void> _onAddEntry(
    AddEntry event,
    Emitter<MoodMirrorState> emit,
  ) {
    // 1. Analyze text
    final textAnalysis = _textAnalyzer.analyze(event.note);

    // 2. Derive weather
    final weather = _weatherEngine.derive(
      event.mood,
      event.context,
      event.energy,
      textAnalysis,
    );

    // 3. Calculate intensity
    final intensity = _intensityCalculator.calculate(
      event.energy,
      textAnalysis,
      event.mood,
    );

    // 4. Analyze reflection
    final reflection = _reflectionAnalyzer.analyze(
      event.mood,
      event.energy,
      textAnalysis,
      weather,
    );

    // 5. Create entry
    final entry = MoodEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      note: event.note,
      energyLevel: event.energy,
      mood: event.mood,
      context: event.context,
      derivedWeather: weather,
      derivedIntensity: intensity,
      derivedReflection: reflection,
      textAnalysis: textAnalysis,
    );

    // 6. Add to entries list (newest first)
    final updatedEntries = [entry, ...state.entries];

    // 7. Generate summary
    final summary = _summaryGenerator.generate(updatedEntries);

    // 8. Apply current filter to new entries
    final filteredEntries = _applyFilter(
      updatedEntries,
      state.currentFilter,
    );

    emit(
      state.copyWith(
        entries: updatedEntries,
        filteredEntries: filteredEntries,
        daySummary: summary,
      ),
    );
  }

  FutureOr<void> _onDeleteEntry(
    DeleteEntry event,
    Emitter<MoodMirrorState> emit,
  ) {
    final updatedEntries = state.entries
        .where((entry) => entry.id != event.id)
        .toList();

    final summary = _summaryGenerator.generate(updatedEntries);

    final filteredEntries = _applyFilter(
      updatedEntries,
      state.currentFilter,
    );

    emit(
      state.copyWith(
        entries: updatedEntries,
        filteredEntries: filteredEntries,
        daySummary: summary,
      ),
    );
  }

  FutureOr<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<MoodMirrorState> emit,
  ) {
    final filteredEntries = _applyFilter(
      state.entries,
      event.filterOptions,
    );

    emit(
      state.copyWith(
        filteredEntries: filteredEntries,
        currentFilter: event.filterOptions,
      ),
    );
  }

  FutureOr<void> _onClearFilter(
    ClearFilter event,
    Emitter<MoodMirrorState> emit,
  ) {
    const defaultFilter = FilterOptions(filterType: FilterType.all);

    emit(
      state.copyWith(
        filteredEntries: state.entries,
        currentFilter: defaultFilter,
      ),
    );
  }

  List<MoodEntry> _applyFilter(
    List<MoodEntry> entries,
    FilterOptions filterOptions,
  ) {
    switch (filterOptions.filterType) {
      case FilterType.all:
        return entries;

      case FilterType.highIntensity:
        return entries
            .where((entry) => entry.derivedIntensity == IntensityLevel.high)
            .toList();

      case FilterType.contradictory:
        return entries
            .where((entry) =>
                entry.derivedReflection == ReflectionFlag.mixed ||
                entry.derivedReflection == ReflectionFlag.overloaded)
            .toList();

      case FilterType.byContext:
        if (filterOptions.selectedContext == null) {
          return entries;
        }
        return entries
            .where((entry) => entry.context == filterOptions.selectedContext)
            .toList();
    }
  }
}
