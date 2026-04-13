import 'package:bloc/bloc.dart';
import 'package:my_appp/domain/models/issue_report.dart';
import 'package:my_appp/domain/repositories/issue_repository.dart';
import 'package:my_appp/presentation/issue_form/bloc/issue_form_event.dart';
import 'package:my_appp/presentation/issue_form/bloc/issue_form_state.dart';
import 'package:uuid/uuid.dart';

/// BLoC for managing the issue reporting form state and submission.
class IssueFormBloc extends Bloc<IssueFormEvent, IssueFormState> {
  /// Creates an issue form BLoC.
  IssueFormBloc({
    required IssueRepository issueRepository,
  })  : _issueRepository = issueRepository,
        super(const IssueFormState()) {
    on<IssueFormNameChanged>(_onNameChanged);
    on<IssueFormBodyChanged>(_onBodyChanged);
    on<IssueFormAddressChanged>(_onAddressChanged);
    on<IssueFormDirectionChanged>(_onDirectionChanged);
    on<IssueFormZoneChanged>(_onZoneChanged);
    on<IssueFormImageChanged>(_onImageChanged);
    on<IssueFormSubmitted>(_onSubmitted);
    on<IssueFormReset>(_onReset);
  }

  final IssueRepository _issueRepository;
  final Uuid _uuid = const Uuid();

  void _onNameChanged(
    IssueFormNameChanged event,
    Emitter<IssueFormState> emit,
  ) {
    emit(state.copyWith(reporterName: event.name, clearError: true));
  }

  void _onBodyChanged(
    IssueFormBodyChanged event,
    Emitter<IssueFormState> emit,
  ) {
    emit(state.copyWith(governmentBody: event.governmentBody, clearError: true));
  }

  void _onAddressChanged(
    IssueFormAddressChanged event,
    Emitter<IssueFormState> emit,
  ) {
    emit(state.copyWith(address: event.address, clearError: true));
  }

  void _onDirectionChanged(
    IssueFormDirectionChanged event,
    Emitter<IssueFormState> emit,
  ) {
    emit(state.copyWith(direction: event.direction, clearError: true));
  }

  void _onZoneChanged(
    IssueFormZoneChanged event,
    Emitter<IssueFormState> emit,
  ) {
    emit(state.copyWith(zone: event.zone, clearError: true));
  }

  void _onImageChanged(
    IssueFormImageChanged event,
    Emitter<IssueFormState> emit,
  ) {
    emit(
      state.copyWith(
        imagePath: event.imagePath,
        clearImage: event.imagePath == null,
        clearError: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    IssueFormSubmitted event,
    Emitter<IssueFormState> emit,
  ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: 'Please fill all required fields correctly.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting));

    try {
      final issue = IssueReport(
        id: _uuid.v4(),
        reporterName: state.reporterName.trim(),
        governmentBody: state.governmentBody!,
        address: state.address.trim(),
        direction: state.direction!,
        zone: state.zone!,
        imagePath: state.imagePath,
        reportedAt: DateTime.now(),
      );

      await _issueRepository.addIssue(issue);

      emit(state.copyWith(status: FormStatus.success));
    } on Exception {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: 'Failed to submit issue. Please try again.',
        ),
      );
    }
  }

  void _onReset(
    IssueFormReset event,
    Emitter<IssueFormState> emit,
  ) {
    emit(const IssueFormState());
  }
}
