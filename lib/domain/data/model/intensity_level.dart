enum IntensityLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case IntensityLevel.low:
        return 'Low';
      case IntensityLevel.medium:
        return 'Medium';
      case IntensityLevel.high:
        return 'High';
    }
  }
}
