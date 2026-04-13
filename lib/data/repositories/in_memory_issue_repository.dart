import 'dart:async';

import 'package:my_appp/domain/models/issue_report.dart';
import 'package:my_appp/domain/repositories/issue_repository.dart';

/// In-memory implementation of [IssueRepository].
///
/// Stores issues in memory using a list. Data will be lost when app restarts.
/// Suitable for demo purposes or when persistence is not required.
class InMemoryIssueRepository implements IssueRepository {
  /// Creates an in-memory issue repository.
  InMemoryIssueRepository() {
    _issuesController = StreamController<List<IssueReport>>.broadcast(
      onListen: () {
        _issuesController.add(List.unmodifiable(_issues));
      },
    );
  }

  final List<IssueReport> _issues = [];
  late final StreamController<List<IssueReport>> _issuesController;

  @override
  Future<IssueReport> addIssue(IssueReport issue) async {
    _issues.insert(0, issue); // Add to beginning for newest-first order
    _issuesController.add(List.unmodifiable(_issues));
    return issue;
  }

  @override
  Future<List<IssueReport>> getAllIssues() async {
    return List.unmodifiable(_issues);
  }

  @override
  Future<IssueReport?> getIssueById(String id) async {
    try {
      return _issues.firstWhere((issue) => issue.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Stream<List<IssueReport>> watchAllIssues() {
    return _issuesController.stream;
  }

  /// Disposes the repository and closes streams.
  void dispose() {
    _issuesController.close();
  }
}
