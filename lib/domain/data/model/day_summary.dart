import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/weather_state.dart';

class DaySummary extends Equatable {
  const DaySummary({
    required this.date,
    required this.totalEntries,
    required this.mostFrequentWeather,
    required this.averageEnergy,
    required this.mostCommonContext,
    required this.highIntensityCount,
    required this.contradictoryCount,
    required this.derivedSentence,
    required this.weatherDistribution,
  });

  final DateTime date;
  final int totalEntries;
  final WeatherState? mostFrequentWeather;
  final double averageEnergy;
  final ContextType? mostCommonContext;
  final int highIntensityCount;
  final int contradictoryCount;
  final String derivedSentence;
  final Map<WeatherState, int> weatherDistribution;

  @override
  List<Object?> get props => [
        date,
        totalEntries,
        mostFrequentWeather,
        averageEnergy,
        mostCommonContext,
        highIntensityCount,
        contradictoryCount,
        derivedSentence,
        weatherDistribution,
      ];
}
