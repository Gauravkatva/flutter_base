import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/day_summary.dart';
import 'package:my_appp/domain/data/model/intensity_level.dart';
import 'package:my_appp/domain/data/model/mood_entry.dart';
import 'package:my_appp/domain/data/model/reflection_flag.dart';
import 'package:my_appp/domain/data/model/weather_state.dart';

class SummaryGenerator {
  DaySummary generate(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return DaySummary(
        date: DateTime.now(),
        totalEntries: 0,
        mostFrequentWeather: null,
        averageEnergy: 0,
        mostCommonContext: null,
        highIntensityCount: 0,
        contradictoryCount: 0,
        derivedSentence: 'No entries yet. Start logging your moments!',
        weatherDistribution: {},
      );
    }

    final totalEntries = entries.length;

    // Calculate weather distribution
    final weatherDistribution = <WeatherState, int>{};
    for (final entry in entries) {
      weatherDistribution[entry.derivedWeather] =
          (weatherDistribution[entry.derivedWeather] ?? 0) + 1;
    }

    // Find most frequent weather
    WeatherState? mostFrequentWeather;
    var maxCount = 0;
    weatherDistribution.forEach((weather, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentWeather = weather;
      }
    });

    // Calculate average energy
    final totalEnergy =
        entries.fold<int>(0, (sum, entry) => sum + entry.energyLevel);
    final averageEnergy = totalEnergy / totalEntries;

    // Find most common context
    final contextCounts = <ContextType, int>{};
    for (final entry in entries) {
      contextCounts[entry.context] = (contextCounts[entry.context] ?? 0) + 1;
    }

    ContextType? mostCommonContext;
    maxCount = 0;
    contextCounts.forEach((context, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonContext = context;
      }
    });

    // Count high intensity entries
    final highIntensityCount = entries
        .where((entry) => entry.derivedIntensity == IntensityLevel.high)
        .length;

    // Count contradictory entries
    final contradictoryCount = entries
        .where((entry) =>
            entry.derivedReflection == ReflectionFlag.mixed ||
            entry.derivedReflection == ReflectionFlag.overloaded)
        .length;

    // Generate derived sentence
    final derivedSentence = _generateSentence(
      totalEntries: totalEntries,
      mostFrequentWeather: mostFrequentWeather,
      averageEnergy: averageEnergy,
      mostCommonContext: mostCommonContext,
      highIntensityCount: highIntensityCount,
      contradictoryCount: contradictoryCount,
      entries: entries,
    );

    return DaySummary(
      date: DateTime.now(),
      totalEntries: totalEntries,
      mostFrequentWeather: mostFrequentWeather,
      averageEnergy: averageEnergy,
      mostCommonContext: mostCommonContext,
      highIntensityCount: highIntensityCount,
      contradictoryCount: contradictoryCount,
      derivedSentence: derivedSentence,
      weatherDistribution: weatherDistribution,
    );
  }

  String _generateSentence({
    required int totalEntries,
    required WeatherState? mostFrequentWeather,
    required double averageEnergy,
    required ContextType? mostCommonContext,
    required int highIntensityCount,
    required int contradictoryCount,
    required List<MoodEntry> entries,
  }) {
    // Single entry case
    if (totalEntries == 1) {
      return 'Your first entry has been logged. Keep tracking your moments!';
    }

    // Build sentence parts
    final parts = <String>[];

    // Weather pattern
    if (mostFrequentWeather != null) {
      switch (mostFrequentWeather) {
        case WeatherState.clear:
          parts.add('Your day appears mostly positive and clear');
        case WeatherState.cloudy:
          parts.add('Your day shows moderate and steady patterns');
        case WeatherState.windy:
          parts.add('Your day appears emotionally inconsistent');
        case WeatherState.stormy:
          parts.add('Your day shows signs of stress and tension');
        case WeatherState.foggy:
          parts.add('Your day reflects confusion or low energy');
      }
    }

    // Energy assessment
    if (averageEnergy < 2.5) {
      parts.add('with notably low energy levels');
    } else if (averageEnergy > 3.5) {
      parts.add('with strong energy levels');
    }

    // Context focus
    if (mostCommonContext != null) {
      final contextName = mostCommonContext.displayName.toLowerCase();
      if (highIntensityCount > totalEntries / 2) {
        parts.add('Most high-intensity moments are $contextName-related');
      } else {
        parts.add('with focus on $contextName');
      }
    }

    // Contradiction assessment
    if (contradictoryCount > totalEntries * 0.6) {
      parts.add('Inputs show significant contradictions');
    } else if (contradictoryCount > totalEntries * 0.3) {
      parts.add('with some mixed signals');
    } else if (contradictoryCount == 0) {
      parts.add('Signals are mostly stable and aligned');
    }

    // Recovery check
    final recoveringCount = entries
        .where((entry) => entry.derivedReflection == ReflectionFlag.recovering)
        .length;
    if (recoveringCount > 0) {
      parts.add('but signals suggest recovery');
    }

    // Join parts intelligently
    if (parts.isEmpty) {
      return 'Your day is being tracked. $totalEntries entries logged.';
    }

    // Combine parts
    var sentence = parts.first;
    if (parts.length > 1) {
      for (var i = 1; i < parts.length; i++) {
        if (parts[i].startsWith('Most') ||
            parts[i].startsWith('Inputs') ||
            parts[i].startsWith('Signals')) {
          sentence += '. ${parts[i]}';
        } else {
          sentence += ', ${parts[i]}';
        }
      }
    }

    // Ensure sentence ends with period
    if (!sentence.endsWith('.')) {
      sentence += '.';
    }

    return sentence;
  }
}
