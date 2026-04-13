import 'package:equatable/equatable.dart';

/// Base class for all issue feed events.
sealed class IssueFeedEvent extends Equatable {
  const IssueFeedEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load all issues from the repository.
final class IssueFeedLoaded extends IssueFeedEvent {
  const IssueFeedLoaded();
}

/// Event triggered when the issues stream emits new data.
final class IssueFeedUpdated extends IssueFeedEvent {
  const IssueFeedUpdated();
}
