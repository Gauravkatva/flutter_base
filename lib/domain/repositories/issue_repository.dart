import 'package:my_appp/domain/models/issue_report.dart';

/// Abstract repository for managing civic issue reports.
///
/// This interface defines the contract for issue data operations,
/// allowing different implementations (in-memory, local DB, API, etc.)
/// following the Dependency Inversion Principle.
abstract class IssueRepository {
  /// Adds a new issue report to the repository.
  ///
  /// Returns the added issue report with its assigned ID.
  Future<IssueReport> addIssue(IssueReport issue);

  /// Retrieves all issue reports.
  ///
  /// Returns a list of all issues, typically ordered by reported date (newest first).
  Future<List<IssueReport>> getAllIssues();

  /// Retrieves a specific issue by its ID.
  ///
  /// Returns the issue if found, null otherwise.
  Future<IssueReport?> getIssueById(String id);

  /// Stream of all issues for real-time updates.
  ///
  /// Emits the updated list whenever issues are added or modified.
  Stream<List<IssueReport>> watchAllIssues();
}
