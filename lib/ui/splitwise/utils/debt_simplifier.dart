import 'dart:math';

import 'package:my_appp/domain/data/model/expense_model.dart';
import 'package:my_appp/domain/data/model/split_user.dart';
import 'package:my_appp/domain/data/model/transaction_model.dart';

/// Utility class for debt simplification using greedy algorithm
/// Follows Single Responsibility Principle - only handles debt optimization
class DebtSimplifier {
  const DebtSimplifier._();

  /// Calculate net balance for each user across all expenses
  ///
  /// Returns a map of userId to net balance:
  /// - Positive balance: User should receive money
  /// - Negative balance: User owes money
  /// - Zero: User is settled up
  static Map<String, double> calculateNetBalances({
    required List<ExpenseModel> expenses,
    required List<SplitUser> users,
  }) {
    // Initialize all users with 0 balance
    final balances = <String, double>{};
    for (final user in users) {
      balances[user.id] = 0;
    }

    // Process each expense
    for (final expense in expenses) {
      // Person who paid gets credited
      balances[expense.paidBy.id] =
          (balances[expense.paidBy.id] ?? 0) + expense.totalAmount;

      // Each person in the split gets debited
      for (final split in expense.splits) {
        balances[split.userId] = (balances[split.userId] ?? 0) - split.amount;
      }
    }

    return balances;
  }

  /// Simplify debts using greedy algorithm
  ///
  /// Returns a minimal set of transactions needed to settle all debts
  ///
  /// Algorithm:
  /// 1. Calculate net balances
  /// 2. Separate creditors (positive balance) and debtors (negative balance)
  /// 3. Sort both lists in descending order of absolute value
  /// 4. Match largest debtor with largest creditor iteratively
  /// 5. Create transactions for the minimum of what debtor owes and creditor is owed
  static List<TransactionModel> simplifyDebts({
    required List<ExpenseModel> expenses,
    required List<SplitUser> users,
  }) {
    if (expenses.isEmpty) {
      return [];
    }

    final netBalances = calculateNetBalances(
      expenses: expenses,
      users: users,
    );

    // Separate creditors and debtors
    final creditors = <_UserBalance>[];
    final debtors = <_UserBalance>[];

    for (final entry in netBalances.entries) {
      final user = users.firstWhere((u) => u.id == entry.key);
      final balance = entry.value;

      // Skip if balanced (with small tolerance for rounding errors)
      if (balance.abs() < 0.01) continue;

      if (balance > 0) {
        creditors.add(_UserBalance(userId: user.id, userName: user.name, balance: balance));
      } else {
        debtors.add(_UserBalance(userId: user.id, userName: user.name, balance: balance.abs()));
      }
    }

    // Sort in descending order for optimization
    creditors.sort((a, b) => b.balance.compareTo(a.balance));
    debtors.sort((a, b) => b.balance.compareTo(a.balance));

    // Generate simplified transactions
    return _generateTransactions(creditors, debtors);
  }

  /// Generate minimal transactions from creditors and debtors lists
  static List<TransactionModel> _generateTransactions(
    List<_UserBalance> creditors,
    List<_UserBalance> debtors,
  ) {
    final transactions = <TransactionModel>[];
    var transactionId = 1;

    var i = 0; // Creditor index
    var j = 0; // Debtor index

    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];

      // Amount to transfer is minimum of what creditor is owed and debtor owes
      final amount = min(creditor.balance, debtor.balance);

      // Create transaction
      transactions.add(
        TransactionModel(
          id: 'txn_$transactionId',
          fromUserId: debtor.userId,
          fromUserName: debtor.userName,
          toUserId: creditor.userId,
          toUserName: creditor.userName,
          amount: amount,
        ),
      );

      transactionId++;

      // Update balances
      creditor.balance -= amount;
      debtor.balance -= amount;

      // Move to next creditor if current one is settled
      if (creditor.balance < 0.01) {
        i++;
      }

      // Move to next debtor if current one is settled
      if (debtor.balance < 0.01) {
        j++;
      }
    }

    return transactions;
  }

  /// Get settlement summary for display
  ///
  /// Returns a human-readable summary of who owes whom
  static String getSettlementSummary(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return 'All settled up! 🎉';
    }

    final summary = StringBuffer();
    summary.writeln('Settlement Summary:');
    summary.writeln('');

    for (var i = 0; i < transactions.length; i++) {
      final txn = transactions[i];
      summary.writeln(
        '${i + 1}. ${txn.fromUserName} pays ${txn.toUserName} ${txn.formattedAmount}',
      );
    }

    return summary.toString();
  }

  /// Calculate total money owed by a specific user
  static double getTotalOwed(String userId, Map<String, double> balances) {
    final balance = balances[userId] ?? 0;
    return balance < 0 ? balance.abs() : 0;
  }

  /// Calculate total money to be received by a specific user
  static double getTotalToReceive(String userId, Map<String, double> balances) {
    final balance = balances[userId] ?? 0;
    return balance > 0 ? balance : 0;
  }
}

/// Internal class to hold user balance information during simplification
class _UserBalance {
  _UserBalance({
    required this.userId,
    required this.userName,
    required this.balance,
  });

  final String userId;
  final String userName;
  double balance;
}
