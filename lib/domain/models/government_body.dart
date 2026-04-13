/// Represents different government departments responsible for civic issues.
enum GovernmentBody {
  /// Water supply, drainage, and sewage management
  waterBodies('Water Bodies'),

  /// Road maintenance, traffic, and street infrastructure
  roadsBodies('Roads Body'),

  /// Public buildings, bridges, and general infrastructure
  publicInfrastructure('Public Infrastructure'),

  /// Waste management, cleaning, and sanitation
  sanitationDepartment('Sanitation Department'),

  /// Power supply and electrical infrastructure
  electricityBoard('Electricity Board'),

  /// Parks, gardens, and recreational facilities
  parksAndRecreation('Parks & Recreation');

  const GovernmentBody(this.displayName);

  /// Human-readable name for the government body
  final String displayName;
}
