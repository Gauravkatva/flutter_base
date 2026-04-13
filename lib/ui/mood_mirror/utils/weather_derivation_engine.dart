import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/mood_type.dart';
import 'package:my_appp/domain/data/model/text_analysis_result.dart';
import 'package:my_appp/domain/data/model/weather_state.dart';

class WeatherDerivationEngine {
  WeatherState derive(
    MoodType mood,
    ContextType context,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    // Check for contradictions first - these lead to Windy (unsettled)
    if (_hasContradiction(mood, energy, textAnalysis)) {
      return WeatherState.windy;
    }

    // Stormy: High stress, negative sentiment, tense mood
    if (_isStormy(mood, energy, textAnalysis)) {
      return WeatherState.stormy;
    }

    // Foggy: Confusion, unclear signals, low energy with drained mood
    if (_isFoggy(mood, energy, textAnalysis)) {
      return WeatherState.foggy;
    }

    // Clear: Positive mood, high energy, positive sentiment
    if (_isClear(mood, energy, textAnalysis)) {
      return WeatherState.clear;
    }

    // Cloudy: Neutral or slightly negative, moderate signals
    if (_isCloudy(mood, energy, textAnalysis)) {
      return WeatherState.cloudy;
    }

    // Default to Cloudy for ambiguous cases
    return WeatherState.cloudy;
  }

  bool _hasContradiction(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    // Happy/Focused with low energy
    if ((mood == MoodType.happy || mood == MoodType.focused) && energy <= 2) {
      return true;
    }

    // Drained/Tense with high energy
    if ((mood == MoodType.drained || mood == MoodType.tense) && energy >= 4) {
      return true;
    }

    // Calm with very high punctuation
    if (mood == MoodType.calm && textAnalysis.punctuationDensity > 0.15) {
      return true;
    }

    // Positive mood with strongly negative text
    if ((mood == MoodType.happy || mood == MoodType.calm) &&
        textAnalysis.sentimentScore < -0.3) {
      return true;
    }

    // Negative mood with strongly positive text
    if ((mood == MoodType.drained || mood == MoodType.tense) &&
        textAnalysis.sentimentScore > 0.3) {
      return true;
    }

    return false;
  }

  bool _isStormy(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    // Tense mood with stress keywords
    if (mood == MoodType.tense && textAnalysis.stressKeywordCount > 0) {
      return true;
    }

    // High stress with high punctuation
    if (textAnalysis.stressKeywordCount >= 2 &&
        textAnalysis.punctuationDensity > 0.1) {
      return true;
    }

    // Strongly negative sentiment with low energy
    if (textAnalysis.sentimentScore < -0.5 && energy <= 2) {
      return true;
    }

    return false;
  }

  bool _isFoggy(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    // Drained with low energy and negative sentiment
    if (mood == MoodType.drained &&
        energy <= 2 &&
        textAnalysis.sentimentScore < 0) {
      return true;
    }

    // Very low energy with negative keywords
    if (energy == 1 && textAnalysis.negativeKeywordCount > 0) {
      return true;
    }

    // Unclear signals (neutral sentiment, moderate energy)
    if (textAnalysis.sentimentScore.abs() < 0.1 &&
        energy == 3 &&
        mood == MoodType.drained) {
      return true;
    }

    return false;
  }

  bool _isClear(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    // Happy with high energy and positive sentiment
    if (mood == MoodType.happy &&
        energy >= 4 &&
        textAnalysis.sentimentScore > 0.2) {
      return true;
    }

    // Calm with positive sentiment and low stress
    if (mood == MoodType.calm &&
        textAnalysis.sentimentScore > 0 &&
        textAnalysis.stressKeywordCount == 0) {
      return true;
    }

    // Focused with high energy and minimal negative signals
    if (mood == MoodType.focused &&
        energy >= 4 &&
        textAnalysis.negativeKeywordCount == 0) {
      return true;
    }

    return false;
  }

  bool _isCloudy(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    // Focused with moderate energy
    if (mood == MoodType.focused && energy >= 2 && energy <= 4) {
      return true;
    }

    // Calm with moderate signals
    if (mood == MoodType.calm && energy >= 2) {
      return true;
    }

    // Neutral sentiment
    if (textAnalysis.sentimentScore.abs() < 0.3) {
      return true;
    }

    return false;
  }
}
