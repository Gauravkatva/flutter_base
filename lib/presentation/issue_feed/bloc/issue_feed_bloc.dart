import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:my_appp/domain/models/issue_report.dart';
import 'package:my_appp/domain/repositories/issue_repository.dart';
import 'package:my_appp/presentation/issue_feed/bloc/issue_feed_event.dart';
import 'package:my_appp/presentation/issue_feed/bloc/issue_feed_state.dart';

/// BLoC for managing the issue feed state and loading issues.
class IssueFeedBloc extends Bloc<IssueFeedEvent, IssueFeedState> {
  /// Creates an issue feed BLoC.
  IssueFeedBloc({
    required IssueRepository issueRepository,
  })  : _issueRepository = issueRepository,
        super(const IssueFeedState()) {
    on<IssueFeedLoaded>(_onLoaded);
    on<IssueFeedUpdated>(_onUpdated);

    // Subscribe to repository stream for real-time updates
    _issuesSubscription = _issueRepository.watchAllIssues().listen(
      (issues) {
        add(const IssueFeedUpdated());
      },
    );
  }

  final IssueRepository _issueRepository;
  StreamSubscription<List<IssueReport>>? _issuesSubscription;

  Future<void> _onLoaded(
    IssueFeedLoaded event,
    Emitter<IssueFeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));

    try {
      final issues = await _issueRepository.getAllIssues();
      emit(
        state.copyWith(
          issues: issues,
          status: FeedStatus.loaded,
          clearError: true,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: 'Failed to load issues. Please try again.',
        ),
      );
    }
  }

  Future<void> _onUpdated(
    IssueFeedUpdated event,
    Emitter<IssueFeedState> emit,
  ) async {
    try {
      final issues = await _issueRepository.getAllIssues();
      emit(
        state.copyWith(
          issues: issues,
          status: FeedStatus.loaded,
          clearError: true,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: 'Failed to update issues.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _issuesSubscription?.cancel();
    return super.close();
  }
}
