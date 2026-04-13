import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/models/government_body.dart';
import 'package:my_appp/domain/models/location_direction.dart';
import 'package:my_appp/domain/models/zone.dart';

/// Represents a civic issue reported by a citizen.
class IssueReport extends Equatable {
  /// Creates a new issue report.
  const IssueReport({
    required this.id,
    required this.reporterName,
    required this.governmentBody,
    required this.address,
    required this.direction,
    required this.zone,
    required this.reportedAt,
    this.imagePath,
  });

  /// Unique identifier for the issue
  final String id;

  /// Name of the person reporting the issue
  final String reporterName;

  /// Government department responsible for handling this issue
  final GovernmentBody governmentBody;

  /// Detailed address where the issue is located
  final String address;

  /// Cardinal direction of the location
  final LocationDirection direction;

  /// Municipal zone where the issue is located
  final Zone zone;

  /// Optional path to the image showing the issue
  final String? imagePath;

  /// Timestamp when the issue was reported
  final DateTime reportedAt;

  /// Returns a copy of this issue with updated fields.
  IssueReport copyWith({
    String? id,
    String? reporterName,
    GovernmentBody? governmentBody,
    String? address,
    LocationDirection? direction,
    Zone? zone,
    String? imagePath,
    DateTime? reportedAt,
  }) {
    return IssueReport(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      governmentBody: governmentBody ?? this.governmentBody,
      address: address ?? this.address,
      direction: direction ?? this.direction,
      zone: zone ?? this.zone,
      imagePath: imagePath ?? this.imagePath,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reporterName,
        governmentBody,
        address,
        direction,
        zone,
        imagePath,
        reportedAt,
      ];
}
