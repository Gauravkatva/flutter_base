import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:my_appp/domain/data/model/expense_model.dart';
import 'package:my_appp/domain/data/model/split_user.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_event.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_state.dart';
import 'package:my_appp/ui/splitwise/utils/debt_simplifier.dart';
import 'package:my_appp/ui/splitwise/utils/split_calculator.dart';

/// BLoC for managing SplitWise application state
///
/// Follows Clean Architecture and SOLID principles:
/// - Single Responsibility: Only manages SplitWise state
/// - Dependency Inversion: Uses utility classes for calculations
/// - Open/Closed: Extensible for new split types
class SplitWiseBloc extends Bloc<SplitWiseEvent, SplitWiseState> {
  SplitWiseBloc() : super(const SplitWiseInitial()) {
    on<InitializeSplitWise>(_onInitialize);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<CalculateSimplifiedDebts>(_onCalculateSimplifiedDebts);
    on<SettleTransaction>(_onSettleTransaction);
    on<ClearAllExpenses>(_onClearAllExpenses);
  }

  /// Hardcoded users for the group
  static final List<SplitUser> _defaultUsers = [
    const SplitUser(
      id: 'user_1',
      name: 'Alice',
      avatarColor: Colors.blue,
    ),
    const SplitUser(
      id: 'user_2',
      name: 'Bob',
      avatarColor: Colors.green,
    ),
    const SplitUser(
      id: 'user_3',
      name: 'Charlie',
      avatarColor: Colors.orange,
    ),
    const SplitUser(
      id: 'user_4',
      name: 'Diana',
      avatarColor: Colors.purple,
    ),
  ];

  /// Initialize the app with default users
  Future<void> _onInitialize(
    InitializeSplitWise event,
    Emitter<SplitWiseState> emit,
  ) async {
    emit(const SplitWiseLoading());

    try {
      // Initialize with empty expenses
      emit(
        SplitWiseLoaded(
          users: _defaultUsers,
          expenses: const [],
          netBalances: _initializeBalances(_defaultUsers),
          simplifiedTransactions: const [],
        ),
      );
    } catch (e) {
      emit(SplitWiseError(message: 'Failed to initialize: ${e.toString()}'));
    }
  }

  /// Add a new expense
  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<SplitWiseState> emit,
  ) async {
    if (state is! SplitWiseLoaded) return;

    final currentState = state as SplitWiseLoaded;

    try {
      // Validate input
      if (event.amount <= 0) {
        emit(
          currentState.copyWith(
            errorMessage: 'Amount must be greater than 0',
          ),
        );
        return;
      }

      if (event.description.trim().isEmpty) {
        emit(
          currentState.copyWith(
            errorMessage: 'Description cannot be empty',
          ),
        );
        return;
      }

      // Find the user who paid
      final paidByUser = currentState.users.firstWhere(
        (user) => user.id == event.paidByUserId,
        orElse: () => currentState.users.first,
      );

      // Calculate splits using SplitCalculator utility
      final splits = SplitCalculator.calculateSplits(
        amount: event.amount,
        users: currentState.users,
        splitType: event.splitType,
        splitValues: event.splitValues,
      );

      // Create new expense
      final newExpense = ExpenseModel(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        description: event.description,
        totalAmount: event.amount,
        paidBy: paidByUser,
        splitType: event.splitType,
        splits: splits,
        date: DateTime.now(),
        category: event.category,
      );

      // Verify split is valid
      if (!newExpense.isSplitValid) {
        emit(
          currentState.copyWith(
            errorMessage: 'Split calculation error: amounts do not sum to total',
          ),
        );
        return;
      }

      // Add expense to list
      final updatedExpenses = [...currentState.expenses, newExpense];

      // Recalculate balances and simplified debts
      final netBalances = DebtSimplifier.calculateNetBalances(
        expenses: updatedExpenses,
        users: currentState.users,
      );

      final simplifiedTransactions = DebtSimplifier.simplifyDebts(
        expenses: updatedExpenses,
        users: currentState.users,
      );

      emit(
        currentState.copyWith(
          expenses: updatedExpenses,
          netBalances: netBalances,
          simplifiedTransactions: simplifiedTransactions,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: 'Failed to add expense: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete an expense
  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<SplitWiseState> emit,
  ) async {
    if (state is! SplitWiseLoaded) return;

    final currentState = state as SplitWiseLoaded;

    try {
      // Remove expense from list
      final updatedExpenses = currentState.expenses
          .where((expense) => expense.id != event.expenseId)
          .toList();

      // Recalculate balances and simplified debts
      final netBalances = DebtSimplifier.calculateNetBalances(
        expenses: updatedExpenses,
        users: currentState.users,
      );

      final simplifiedTransactions = DebtSimplifier.simplifyDebts(
        expenses: updatedExpenses,
        users: currentState.users,
      );

      emit(
        currentState.copyWith(
          expenses: updatedExpenses,
          netBalances: netBalances,
          simplifiedTransactions: simplifiedTransactions,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: 'Failed to delete expense: ${e.toString()}',
        ),
      );
    }
  }

  /// Recalculate simplified debts
  Future<void> _onCalculateSimplifiedDebts(
    CalculateSimplifiedDebts event,
    Emitter<SplitWiseState> emit,
  ) async {
    if (state is! SplitWiseLoaded) return;

    final currentState = state as SplitWiseLoaded;

    try {
      final simplifiedTransactions = DebtSimplifier.simplifyDebts(
        expenses: currentState.expenses,
        users: currentState.users,
      );

      emit(
        currentState.copyWith(
          simplifiedTransactions: simplifiedTransactions,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: 'Failed to calculate debts: ${e.toString()}',
        ),
      );
    }
  }

  /// Mark a transaction as settled
  Future<void> _onSettleTransaction(
    SettleTransaction event,
    Emitter<SplitWiseState> emit,
  ) async {
    if (state is! SplitWiseLoaded) return;

    final currentState = state as SplitWiseLoaded;

    try {
      // Update transaction status
      final updatedTransactions = currentState.simplifiedTransactions
          .map(
            (txn) => txn.id == event.transactionId ? txn.markAsSettled() : txn,
          )
          .toList();

      emit(
        currentState.copyWith(
          simplifiedTransactions: updatedTransactions,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: 'Failed to settle transaction: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear all expenses
  Future<void> _onClearAllExpenses(
    ClearAllExpenses event,
    Emitter<SplitWiseState> emit,
  ) async {
    if (state is! SplitWiseLoaded) return;

    final currentState = state as SplitWiseLoaded;

    emit(
      currentState.copyWith(
        expenses: const [],
        netBalances: _initializeBalances(currentState.users),
        simplifiedTransactions: const [],
      ),
    );
  }

  /// Initialize balances map with all users at 0
  static Map<String, double> _initializeBalances(List<SplitUser> users) {
    return {for (final user in users) user.id: 0.0};
  }
}
