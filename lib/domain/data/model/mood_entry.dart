import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/intensity_level.dart';
import 'package:my_appp/domain/data/model/mood_type.dart';
import 'package:my_appp/domain/data/model/reflection_flag.dart';
import 'package:my_appp/domain/data/model/text_analysis_result.dart';
import 'package:my_appp/domain/data/model/weather_state.dart';

class MoodEntry extends Equatable {
  const MoodEntry({
    required this.id,
    required this.timestamp,
    required this.note,
    required this.energyLevel,
    required this.mood,
    required this.context,
    required this.derivedWeather,
    required this.derivedIntensity,
    required this.derivedReflection,
    required this.textAnalysis,
  });

  final String id;
  final DateTime timestamp;
  final String note;
  final int energyLevel;
  final MoodType mood;
  final ContextType context;
  final WeatherState derivedWeather;
  final IntensityLevel derivedIntensity;
  final ReflectionFlag derivedReflection;
  final TextAnalysisResult textAnalysis;

  @override
  List<Object?> get props => [
        id,
        timestamp,
        note,
        energyLevel,
        mood,
        context,
        derivedWeather,
        derivedIntensity,
        derivedReflection,
        textAnalysis,
      ];
}
