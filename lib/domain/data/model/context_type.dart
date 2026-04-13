enum ContextType {
  work,
  family,
  health,
  social,
  alone;

  String get displayName {
    switch (this) {
      case ContextType.work:
        return 'Work';
      case ContextType.family:
        return 'Family';
      case ContextType.health:
        return 'Health';
      case ContextType.social:
        return 'Social';
      case ContextType.alone:
        return 'Alone';
    }
  }
}
