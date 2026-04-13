enum MoodType {
  calm,
  tense,
  happy,
  drained,
  focused;

  String get displayName {
    switch (this) {
      case MoodType.calm:
        return 'Calm';
      case MoodType.tense:
        return 'Tense';
      case MoodType.happy:
        return 'Happy';
      case MoodType.drained:
        return 'Drained';
      case MoodType.focused:
        return 'Focused';
    }
  }
}
