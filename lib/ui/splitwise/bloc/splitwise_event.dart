import 'package:equatable/equatable.dart';

import 'package:my_appp/domain/data/model/split_type.dart';

/// Base class for all SplitWise events
sealed class SplitWiseEvent extends Equatable {
  const SplitWiseEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the app with hardcoded users
final class InitializeSplitWise extends SplitWiseEvent {
  const InitializeSplitWise();
}

/// Event to add a new expense
final class AddExpense extends SplitWiseEvent {
  const AddExpense({
    required this.description,
    required this.amount,
    required this.paidByUserId,
    required this.splitType,
    required this.splitValues,
    this.category,
  });

  final String description;
  final double amount;
  final String paidByUserId;
  final SplitType splitType;
  final Map<String, double> splitValues;
  final String? category;

  @override
  List<Object?> get props => [
        description,
        amount,
        paidByUserId,
        splitType,
        splitValues,
        category,
      ];
}

/// Event to delete an expense
final class DeleteExpense extends SplitWiseEvent {
  const DeleteExpense({required this.expenseId});

  final String expenseId;

  @override
  List<Object?> get props => [expenseId];
}

/// Event to calculate and update simplified debts
final class CalculateSimplifiedDebts extends SplitWiseEvent {
  const CalculateSimplifiedDebts();
}

/// Event to mark a transaction as settled
final class SettleTransaction extends SplitWiseEvent {
  const SettleTransaction({required this.transactionId});

  final String transactionId;

  @override
  List<Object?> get props => [transactionId];
}

/// Event to load expense history (for future persistence)
final class LoadExpenseHistory extends SplitWiseEvent {
  const LoadExpenseHistory();
}

/// Event to clear all expenses
final class ClearAllExpenses extends SplitWiseEvent {
  const ClearAllExpenses();
}
