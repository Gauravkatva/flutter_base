/// Represents different zones in the municipal area.
enum Zone {
  /// Zone 1
  z1('Z1'),

  /// Zone 2
  z2('Z2'),

  /// Zone 3
  z3('Z3'),

  /// Zone 4
  z4('Z4'),

  /// Zone 5
  z5('Z5'),

  /// Zone 6
  z6('Z6');

  const Zone(this.displayName);

  /// Human-readable name for the zone
  final String displayName;
}
