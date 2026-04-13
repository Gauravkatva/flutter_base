import 'package:my_appp/domain/data/model/mood_type.dart';
import 'package:my_appp/domain/data/model/reflection_flag.dart';
import 'package:my_appp/domain/data/model/text_analysis_result.dart';
import 'package:my_appp/domain/data/model/weather_state.dart';

class ReflectionAnalyzer {
  ReflectionFlag analyze(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
    WeatherState weather,
  ) {
    final contradictionScore = _calculateContradictionScore(
      mood,
      energy,
      textAnalysis,
    );

    // Check for recovering pattern
    if (_isRecovering(mood, energy, textAnalysis, contradictionScore)) {
      return ReflectionFlag.recovering;
    }

    // Check for overloaded pattern
    if (_isOverloaded(mood, energy, textAnalysis, contradictionScore)) {
      return ReflectionFlag.overloaded;
    }

    // Check for unclear pattern
    if (_isUnclear(textAnalysis, contradictionScore)) {
      return ReflectionFlag.unclear;
    }

    // Map contradiction score to flags
    if (contradictionScore < 0.5) {
      return ReflectionFlag.stable;
    } else if (contradictionScore < 1.5) {
      return ReflectionFlag.mixed;
    } else {
      return ReflectionFlag.overloaded;
    }
  }

  double _calculateContradictionScore(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
  ) {
    var score = 0.0;

    // Mood-Energy contradictions
    if ((mood == MoodType.happy || mood == MoodType.focused) && energy <= 2) {
      score += 0.7;
    }
    if ((mood == MoodType.drained || mood == MoodType.tense) && energy >= 4) {
      score += 0.7;
    }
    if (mood == MoodType.calm && (energy == 1 || energy == 5)) {
      score += 0.5;
    }

    // Mood-Text contradictions
    if ((mood == MoodType.happy || mood == MoodType.calm) &&
        textAnalysis.sentimentScore < -0.3) {
      score += 0.8;
    }
    if ((mood == MoodType.drained || mood == MoodType.tense) &&
        textAnalysis.sentimentScore > 0.3) {
      score += 0.7;
    }
    if (mood == MoodType.calm && textAnalysis.punctuationDensity > 0.15) {
      score += 0.6;
    }
    if (mood == MoodType.happy && textAnalysis.stressKeywordCount > 0) {
      score += 0.7;
    }

    // Energy-Text contradictions
    if (energy >= 4 && textAnalysis.sentimentScore < -0.2) {
      score += 0.5;
    }
    if (energy <= 2 && textAnalysis.punctuationDensity > 0.1) {
      score += 0.6;
    }

    return score;
  }

  bool _isRecovering(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
    double contradictionScore,
  ) {
    // Positive trend with low energy (recovering from drain)
    if (contradictionScore > 0.5 &&
        energy <= 2 &&
        textAnalysis.sentimentScore > 0.2) {
      return true;
    }

    // Recovery keywords present with low/moderate energy
    if (textAnalysis.recoveryKeywordCount > 0 && energy <= 3) {
      return true;
    }

    // Drained mood but positive text
    if (mood == MoodType.drained && textAnalysis.sentimentScore > 0.3) {
      return true;
    }

    return false;
  }

  bool _isOverloaded(
    MoodType mood,
    int energy,
    TextAnalysisResult textAnalysis,
    double contradictionScore,
  ) {
    // High stress with high contradiction
    if (textAnalysis.stressKeywordCount >= 2 && contradictionScore > 1.0) {
      return true;
    }

    // Focused mood with very low energy and negative sentiment
    if (mood == MoodType.focused &&
        energy == 1 &&
        textAnalysis.sentimentScore < 0) {
      return true;
    }

    // Drained with high punctuation and low energy
    if (mood == MoodType.drained &&
        energy <= 2 &&
        textAnalysis.punctuationDensity > 0.12) {
      return true;
    }

    return false;
  }

  bool _isUnclear(
    TextAnalysisResult textAnalysis,
    double contradictionScore,
  ) {
    // Very neutral sentiment with low variance
    if (textAnalysis.sentimentScore.abs() < 0.15 &&
        textAnalysis.punctuationDensity < 0.05 &&
        textAnalysis.noteLength < 20) {
      return true;
    }

    // No clear signals
    if (textAnalysis.positiveKeywordCount == 0 &&
        textAnalysis.negativeKeywordCount == 0 &&
        textAnalysis.stressKeywordCount == 0 &&
        contradictionScore < 0.3) {
      return true;
    }

    return false;
  }
}
