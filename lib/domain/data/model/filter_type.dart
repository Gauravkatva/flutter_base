enum FilterType {
  all,
  highIntensity,
  contradictory,
  byContext;

  String get displayName {
    switch (this) {
      case FilterType.all:
        return 'All';
      case FilterType.highIntensity:
        return 'High Intensity';
      case FilterType.contradictory:
        return 'Mixed/Contradictory';
      case FilterType.byContext:
        return 'By Context';
    }
  }
}
