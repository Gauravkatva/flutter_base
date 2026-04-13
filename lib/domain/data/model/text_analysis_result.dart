import 'package:equatable/equatable.dart';

class TextAnalysisResult extends Equatable {
  const TextAnalysisResult({
    required this.positiveKeywordCount,
    required this.negativeKeywordCount,
    required this.stressKeywordCount,
    required this.recoveryKeywordCount,
    required this.punctuationDensity,
    required this.repeatedWordCount,
    required this.noteLength,
    required this.sentimentScore,
  });

  final int positiveKeywordCount;
  final int negativeKeywordCount;
  final int stressKeywordCount;
  final int recoveryKeywordCount;
  final double punctuationDensity;
  final int repeatedWordCount;
  final int noteLength;
  final double sentimentScore;

  @override
  List<Object?> get props => [
        positiveKeywordCount,
        negativeKeywordCount,
        stressKeywordCount,
        recoveryKeywordCount,
        punctuationDensity,
        repeatedWordCount,
        noteLength,
        sentimentScore,
      ];
}
