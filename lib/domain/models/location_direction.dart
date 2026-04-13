/// Represents the cardinal direction of an issue location.
enum LocationDirection {
  /// Northern part of the area
  north('North'),

  /// Southern part of the area
  south('South'),

  /// Eastern part of the area
  east('East'),

  /// Western part of the area
  west('West');

  const LocationDirection(this.displayName);

  /// Human-readable name for the direction
  final String displayName;
}
