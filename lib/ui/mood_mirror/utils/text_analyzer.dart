import 'dart:math';

import 'package:my_appp/domain/data/model/text_analysis_result.dart';

class TextAnalyzer {
  // Positive keywords (50+)
  static const positiveKeywords = [
    'good',
    'great',
    'happy',
    'excited',
    'amazing',
    'wonderful',
    'productive',
    'accomplished',
    'progress',
    'success',
    'win',
    'love',
    'enjoy',
    'fun',
    'yay',
    'nice',
    'awesome',
    'fantastic',
    'excellent',
    'brilliant',
    'perfect',
    'beautiful',
    'lovely',
    'joy',
    'blessed',
    'grateful',
    'thankful',
    'appreciative',
    'satisfied',
    'content',
    'peaceful',
    'relaxed',
    'calm',
    'energized',
    'motivated',
    'inspired',
    'confident',
    'proud',
    'optimistic',
    'hopeful',
    'positive',
    'better',
    'improved',
    'achieved',
    'completed',
    'done',
    'finished',
    'victory',
    'succeed',
    'thrilled',
    'delighted',
    'pleased',
    'comfortable',
    'easy',
    'smooth',
    'clear',
    'bright',
  ];

  // Negative keywords (50+)
  static const negativeKeywords = [
    'bad',
    'terrible',
    'awful',
    'hate',
    'angry',
    'sad',
    'failed',
    'mistake',
    'wrong',
    'regret',
    'disappointed',
    'frustrated',
    'annoyed',
    'upset',
    'difficult',
    'hard',
    'horrible',
    'worst',
    'miserable',
    'unhappy',
    'depressed',
    'lonely',
    'hurt',
    'pain',
    'suffering',
    'struggle',
    'problem',
    'issue',
    'trouble',
    'worry',
    'concern',
    'fear',
    'scared',
    'afraid',
    'nervous',
    'uncomfortable',
    'weak',
    'tired',
    'exhausted',
    'drained',
    'empty',
    'lost',
    'confused',
    'stuck',
    'hopeless',
    'helpless',
    'failure',
    'loss',
    'defeat',
    'setback',
    'disaster',
    'mess',
    'chaos',
    'broken',
    'damaged',
    'ruined',
  ];

  // Stress keywords (40+)
  static const stressKeywords = [
    'overwhelmed',
    'anxious',
    'stress',
    'stressed',
    'pressure',
    'worried',
    'panic',
    'deadline',
    'rush',
    'urgent',
    'crisis',
    'exhausted',
    'burnout',
    "can't",
    'cannot',
    'impossible',
    'too much',
    'overloaded',
    'swamped',
    'buried',
    'drowning',
    'suffocating',
    'tense',
    'tight',
    'strained',
    'demanding',
    'hectic',
    'chaotic',
    'frantic',
    'racing',
    'burden',
    'weight',
    'heavy',
    'intense',
    'critical',
    'emergency',
    'hurry',
    'late',
    'behind',
    'struggling',
    'barely',
    'hanging',
    'breaking',
    'cracking',
  ];

  // Recovery/Improvement keywords (20+)
  static const recoveryKeywords = [
    'better',
    'improving',
    'recovery',
    'healing',
    'rest',
    'rested',
    'recharged',
    'refreshed',
    'renewed',
    'restored',
    'bouncing back',
    'getting better',
    'on the mend',
    'recovering',
    'progress',
    'improvement',
    'upward',
    'rising',
    'climbing',
    'comeback',
    'resilient',
    'stronger',
    'rebuilding',
  ];

  TextAnalysisResult analyze(String note) {
    final cleanedNote = note.trim().toLowerCase();

    if (cleanedNote.isEmpty) {
      return const TextAnalysisResult(
        positiveKeywordCount: 0,
        negativeKeywordCount: 0,
        stressKeywordCount: 0,
        recoveryKeywordCount: 0,
        punctuationDensity: 0,
        repeatedWordCount: 0,
        noteLength: 0,
        sentimentScore: 0,
      );
    }

    // Count keywords
    final positiveCount = _countKeywords(cleanedNote, positiveKeywords);
    final negativeCount = _countKeywords(cleanedNote, negativeKeywords);
    final stressCount = _countKeywords(cleanedNote, stressKeywords);
    final recoveryCount = _countKeywords(cleanedNote, recoveryKeywords);

    // Calculate punctuation density
    final punctuationDensity = _calculatePunctuationDensity(note);

    // Count repeated words
    final repeatedWordCount = _countRepeatedWords(cleanedNote);

    // Calculate sentiment score (-1 to 1)
    final sentimentScore = _calculateSentimentScore(
      positiveCount,
      negativeCount,
      stressCount,
      recoveryCount,
    );

    return TextAnalysisResult(
      positiveKeywordCount: positiveCount,
      negativeKeywordCount: negativeCount,
      stressKeywordCount: stressCount,
      recoveryKeywordCount: recoveryCount,
      punctuationDensity: punctuationDensity,
      repeatedWordCount: repeatedWordCount,
      noteLength: cleanedNote.length,
      sentimentScore: sentimentScore,
    );
  }

  int _countKeywords(String text, List<String> keywords) {
    var count = 0;
    for (final keyword in keywords) {
      // Match whole words only
      final regex = RegExp(r'\b' + RegExp.escape(keyword) + r'\b');
      count += regex.allMatches(text).length;
    }
    return count;
  }

  double _calculatePunctuationDensity(String text) {
    if (text.isEmpty) return 0;

    // Count exclamation marks, question marks, and ellipsis
    final punctuationCount = '!'.allMatches(text).length +
        '?'.allMatches(text).length +
        '...'.allMatches(text).length * 3;

    return min(punctuationCount / text.length, 1.0);
  }

  int _countRepeatedWords(String text) {
    final words = text.split(RegExp(r'\s+'));
    final wordCounts = <String, int>{};

    for (final word in words) {
      if (word.length > 3) {
        // Only count words longer than 3 chars
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }

    // Count words that appear more than once
    return wordCounts.values.where((count) => count > 1).length;
  }

  double _calculateSentimentScore(
    int positive,
    int negative,
    int stress,
    int recovery,
  ) {
    final totalKeywords = positive + negative + stress + recovery;

    if (totalKeywords == 0) return 0;

    // Positive: +1, Recovery: +0.5, Negative: -1, Stress: -0.7
    final score = (positive * 1.0 + recovery * 0.5 - negative * 1.0 - stress * 0.7) / totalKeywords;

    // Clamp between -1 and 1
    return max(-1.0, min(1.0, score));
  }
}
