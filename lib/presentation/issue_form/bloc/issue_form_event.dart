import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/models/government_body.dart';
import 'package:my_appp/domain/models/location_direction.dart';
import 'package:my_appp/domain/models/zone.dart';

/// Base class for all issue form events.
sealed class IssueFormEvent extends Equatable {
  const IssueFormEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the reporter name field changes.
final class IssueFormNameChanged extends IssueFormEvent {
  const IssueFormNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Event triggered when the government body selection changes.
final class IssueFormBodyChanged extends IssueFormEvent {
  const IssueFormBodyChanged(this.governmentBody);

  final GovernmentBody governmentBody;

  @override
  List<Object?> get props => [governmentBody];
}

/// Event triggered when the address field changes.
final class IssueFormAddressChanged extends IssueFormEvent {
  const IssueFormAddressChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

/// Event triggered when the direction selection changes.
final class IssueFormDirectionChanged extends IssueFormEvent {
  const IssueFormDirectionChanged(this.direction);

  final LocationDirection direction;

  @override
  List<Object?> get props => [direction];
}

/// Event triggered when the zone selection changes.
final class IssueFormZoneChanged extends IssueFormEvent {
  const IssueFormZoneChanged(this.zone);

  final Zone zone;

  @override
  List<Object?> get props => [zone];
}

/// Event triggered when an image is selected or removed.
final class IssueFormImageChanged extends IssueFormEvent {
  const IssueFormImageChanged(this.imagePath);

  final String? imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Event triggered when the form is submitted.
final class IssueFormSubmitted extends IssueFormEvent {
  const IssueFormSubmitted();
}

/// Event triggered to reset the form to its initial state.
final class IssueFormReset extends IssueFormEvent {
  const IssueFormReset();
}
