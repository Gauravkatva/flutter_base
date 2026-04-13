import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/models/government_body.dart';
import 'package:my_appp/domain/models/location_direction.dart';
import 'package:my_appp/domain/models/zone.dart';

/// Represents the status of the issue form submission.
enum FormStatus {
  /// Initial state, form is ready for input
  initial,

  /// Form is being submitted
  submitting,

  /// Form submission was successful
  success,

  /// Form submission failed
  failure,
}

/// Represents the state of the issue form.
class IssueFormState extends Equatable {
  /// Creates an issue form state.
  const IssueFormState({
    this.reporterName = '',
    this.governmentBody,
    this.address = '',
    this.direction,
    this.zone,
    this.imagePath,
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  /// Reporter's name
  final String reporterName;

  /// Selected government body
  final GovernmentBody? governmentBody;

  /// Issue location address
  final String address;

  /// Selected location direction
  final LocationDirection? direction;

  /// Selected zone
  final Zone? zone;

  /// Path to selected image (if any)
  final String? imagePath;

  /// Current form submission status
  final FormStatus status;

  /// Error message (if status is failure)
  final String? errorMessage;

  /// Returns true if all required fields are valid.
  bool get isValid {
    return reporterName.trim().length >= 2 &&
        governmentBody != null &&
        address.trim().length >= 10 &&
        direction != null &&
        zone != null;
  }

  /// Creates a copy of this state with updated fields.
  IssueFormState copyWith({
    String? reporterName,
    GovernmentBody? governmentBody,
    String? address,
    LocationDirection? direction,
    Zone? zone,
    String? imagePath,
    FormStatus? status,
    String? errorMessage,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return IssueFormState(
      reporterName: reporterName ?? this.reporterName,
      governmentBody: governmentBody ?? this.governmentBody,
      address: address ?? this.address,
      direction: direction ?? this.direction,
      zone: zone ?? this.zone,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        reporterName,
        governmentBody,
        address,
        direction,
        zone,
        imagePath,
        status,
        errorMessage,
      ];
}
