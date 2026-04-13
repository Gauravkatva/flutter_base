import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/data/repositories/in_memory_issue_repository.dart';
import 'package:my_appp/domain/repositories/issue_repository.dart';
import 'package:my_appp/presentation/issue_feed/bloc/issue_feed_bloc.dart';
import 'package:my_appp/presentation/issue_feed/view/issue_feed_page.dart';

/// Entry point for the Civic Issue Tracker application.
///
/// Sets up dependency injection and BLoC providers following
/// clean architecture principles.
class CivicTrackerApp extends StatefulWidget {
  const CivicTrackerApp({super.key});

  @override
  State<CivicTrackerApp> createState() => _CivicTrackerAppState();
}

class _CivicTrackerAppState extends State<CivicTrackerApp> {
  late final IssueRepository _issueRepository;

  @override
  void initState() {
    super.initState();
    // Initialize repository (Dependency Injection)
    _issueRepository = InMemoryIssueRepository();
  }

  @override
  void dispose() {
    // Clean up repository
    final repo = _issueRepository;
    if (repo is InMemoryIssueRepository) {
      repo.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide repository to BLoCs
    return RepositoryProvider<IssueRepository>.value(
      value: _issueRepository,
      child: BlocProvider<IssueFeedBloc>(
        create: (context) => IssueFeedBloc(
          issueRepository: context.read<IssueRepository>(),
        ),
        child: const IssueFeedPage(),
      ),
    );
  }
}
