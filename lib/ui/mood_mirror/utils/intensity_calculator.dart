import 'dart:math';

import 'package:my_appp/domain/data/model/intensity_level.dart';
import 'package:my_appp/domain/data/model/mood_type.dart';
import 'package:my_appp/domain/data/model/text_analysis_result.dart';

class IntensityCalculator {
  IntensityLevel calculate(
    int energy,
    TextAnalysisResult textAnalysis,
    MoodType mood,
  ) {
    // Energy weight: 40%
    final energyScore = (energy / 5.0) * 0.4;

    // Punctuation density weight: 30%
    final punctuationScore = textAnalysis.punctuationDensity * 0.3;

    // Sentiment extremity weight: 20%
    final sentimentExtremity = textAnalysis.sentimentScore.abs();
    final sentimentScore = sentimentExtremity * 0.2;

    // Mood intensity weight: 10%
    final moodScore = _getMoodIntensity(mood) * 0.1;

    final totalScore = energyScore + punctuationScore + sentimentScore + moodScore;

    // Clamp to 0-1 range
    final clampedScore = max(0.0, min(1.0, totalScore));

    // Map to intensity levels
    if (clampedScore < 0.4) {
      return IntensityLevel.low;
    } else if (clampedScore < 0.7) {
      return IntensityLevel.medium;
    } else {
      return IntensityLevel.high;
    }
  }

  double _getMoodIntensity(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 0.8;
      case MoodType.tense:
        return 1.0;
      case MoodType.focused:
        return 0.7;
      case MoodType.drained:
        return 0.6;
      case MoodType.calm:
        return 0.3;
    }
  }
}
