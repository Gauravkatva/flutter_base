import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/models/issue_report.dart';

/// Represents the status of the issue feed.
enum FeedStatus {
  /// Initial state, no data loaded yet
  initial,

  /// Feed is currently loading
  loading,

  /// Feed has been loaded successfully
  loaded,

  /// Feed loading failed
  error,
}

/// Represents the state of the issue feed.
class IssueFeedState extends Equatable {
  /// Creates an issue feed state.
  const IssueFeedState({
    this.issues = const [],
    this.status = FeedStatus.initial,
    this.errorMessage,
  });

  /// List of all issue reports
  final List<IssueReport> issues;

  /// Current feed loading status
  final FeedStatus status;

  /// Error message (if status is error)
  final String? errorMessage;

  /// Returns true if the feed is empty and loaded.
  bool get isEmpty => status == FeedStatus.loaded && issues.isEmpty;

  /// Creates a copy of this state with updated fields.
  IssueFeedState copyWith({
    List<IssueReport>? issues,
    FeedStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IssueFeedState(
      issues: issues ?? this.issues,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [issues, status, errorMessage];
}
