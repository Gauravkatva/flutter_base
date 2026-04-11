/// Enum representing different types of expense splits
enum SplitType {
  /// Split amount equally among all participants
  equal,

  /// Split based on percentage allocation (must sum to 100%)
  percentage,

  /// Split based on weightage/ratio
  weightage,
}

extension SplitTypeExtension on SplitType {
  String get displayName {
    switch (this) {
      case SplitType.equal:
        return 'Equal';
      case SplitType.percentage:
        return 'Percentage';
      case SplitType.weightage:
        return 'Weightage';
    }
  }

  String get description {
    switch (this) {
      case SplitType.equal:
        return 'Split equally among all';
      case SplitType.percentage:
        return 'Split by percentage';
      case SplitType.weightage:
        return 'Split by custom ratio';
    }
  }
}
