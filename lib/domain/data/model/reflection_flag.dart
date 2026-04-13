enum ReflectionFlag {
  stable,
  mixed,
  overloaded,
  recovering,
  unclear;

  String get displayName {
    switch (this) {
      case ReflectionFlag.stable:
        return 'Stable';
      case ReflectionFlag.mixed:
        return 'Mixed';
      case ReflectionFlag.overloaded:
        return 'Overloaded';
      case ReflectionFlag.recovering:
        return 'Recovering';
      case ReflectionFlag.unclear:
        return 'Unclear';
    }
  }
}
