import 'package:equatable/equatable.dart';

import 'package:my_appp/domain/data/model/expense_model.dart';
import 'package:my_appp/domain/data/model/split_user.dart';
import 'package:my_appp/domain/data/model/transaction_model.dart';

/// Base class for all SplitWise states
sealed class SplitWiseState extends Equatable {
  const SplitWiseState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
final class SplitWiseInitial extends SplitWiseState {
  const SplitWiseInitial();
}

/// Loading state while processing data
final class SplitWiseLoading extends SplitWiseState {
  const SplitWiseLoading();
}

/// Loaded state with all data
final class SplitWiseLoaded extends SplitWiseState {
  const SplitWiseLoaded({
    required this.users,
    required this.expenses,
    required this.netBalances,
    required this.simplifiedTransactions,
    this.errorMessage,
  });

  /// List of users in the group
  final List<SplitUser> users;

  /// List of all expenses
  final List<ExpenseModel> expenses;

  /// Net balance for each user (userId -> balance)
  /// Positive: user should receive money
  /// Negative: user owes money
  final Map<String, double> netBalances;

  /// Simplified transactions for settlement
  final List<TransactionModel> simplifiedTransactions;

  /// Optional error message for non-critical errors
  final String? errorMessage;

  /// Check if all users are settled up
  bool get isAllSettled => simplifiedTransactions.isEmpty;

  /// Get total number of expenses
  int get totalExpenses => expenses.length;

  /// Get total amount spent across all expenses
  double get totalSpent => expenses.fold(
        0,
        (sum, expense) => sum + expense.totalAmount,
      );

  /// Get formatted total spent
  String get formattedTotalSpent => '₹${totalSpent.toStringAsFixed(2)}';

  SplitWiseLoaded copyWith({
    List<SplitUser>? users,
    List<ExpenseModel>? expenses,
    Map<String, double>? netBalances,
    List<TransactionModel>? simplifiedTransactions,
    String? errorMessage,
  }) {
    return SplitWiseLoaded(
      users: users ?? this.users,
      expenses: expenses ?? this.expenses,
      netBalances: netBalances ?? this.netBalances,
      simplifiedTransactions:
          simplifiedTransactions ?? this.simplifiedTransactions,
      errorMessage: errorMessage,
    );
  }

  /// Clear error message
  SplitWiseLoaded clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  List<Object?> get props => [
        users,
        expenses,
        netBalances,
        simplifiedTransactions,
        errorMessage,
      ];
}

/// Error state
final class SplitWiseError extends SplitWiseState {
  const SplitWiseError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
