import 'package:my_appp/domain/data/model/split_type.dart';
import 'package:my_appp/domain/data/model/split_user.dart';
import 'package:my_appp/domain/data/model/user_split.dart';

/// Utility class for calculating expense splits
/// Follows Single Responsibility Principle - only handles split calculations
class SplitCalculator {
  const SplitCalculator._();

  /// Calculate splits based on split type and values
  ///
  /// Returns a list of [UserSplit] objects representing how much each user owes
  ///
  /// Throws [ArgumentError] if:
  /// - [amount] is <= 0
  /// - [users] is empty
  /// - For percentage: sum != 100
  /// - For weightage: any weight <= 0
  static List<UserSplit> calculateSplits({
    required double amount,
    required List<SplitUser> users,
    required SplitType splitType,
    Map<String, double>? splitValues,
  }) {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }

    if (users.isEmpty) {
      throw ArgumentError('Users list cannot be empty');
    }

    switch (splitType) {
      case SplitType.equal:
        return _calculateEqualSplit(amount, users);
      case SplitType.percentage:
        return _calculatePercentageSplit(amount, users, splitValues ?? {});
      case SplitType.weightage:
        return _calculateWeightageSplit(amount, users, splitValues ?? {});
    }
  }

  /// Calculate equal split among all users
  static List<UserSplit> _calculateEqualSplit(
    double amount,
    List<SplitUser> users,
  ) {
    final perPersonAmount = amount / users.length;

    return users
        .map(
          (user) => UserSplit(
            userId: user.id,
            userName: user.name,
            amount: perPersonAmount,
            splitValue: 1, // Equal share
          ),
        )
        .toList();
  }

  /// Calculate percentage-based split
  ///
  /// Validates that percentages sum to 100
  static List<UserSplit> _calculatePercentageSplit(
    double amount,
    List<SplitUser> users,
    Map<String, double> percentages,
  ) {
    // Validate percentages sum to 100
    final totalPercentage = percentages.values.fold<double>(
      0,
      (sum, percentage) => sum + percentage,
    );

    if ((totalPercentage - 100).abs() > 0.01) {
      throw ArgumentError(
        'Percentages must sum to 100. Current sum: $totalPercentage',
      );
    }

    // Validate all percentages are positive
    if (percentages.values.any((p) => p <= 0)) {
      throw ArgumentError('All percentages must be greater than 0');
    }

    return users.map((user) {
      final percentage = percentages[user.id] ?? 0;
      final userAmount = (amount * percentage) / 100;

      return UserSplit(
        userId: user.id,
        userName: user.name,
        amount: userAmount,
        splitValue: percentage,
      );
    }).toList();
  }

  /// Calculate weightage-based split
  ///
  /// Distributes amount based on relative weights
  static List<UserSplit> _calculateWeightageSplit(
    double amount,
    List<SplitUser> users,
    Map<String, double> weights,
  ) {
    // Validate all weights are positive
    if (weights.values.any((w) => w <= 0)) {
      throw ArgumentError('All weights must be greater than 0');
    }

    final totalWeight = weights.values.fold<double>(
      0,
      (sum, weight) => sum + weight,
    );

    if (totalWeight <= 0) {
      throw ArgumentError('Total weight must be greater than 0');
    }

    return users.map((user) {
      final weight = weights[user.id] ?? 1;
      final userAmount = (amount * weight) / totalWeight;

      return UserSplit(
        userId: user.id,
        userName: user.name,
        amount: userAmount,
        splitValue: weight,
      );
    }).toList();
  }

  /// Validate split values based on split type
  ///
  /// Returns true if valid, throws [ArgumentError] if invalid
  static bool validateSplitValues({
    required SplitType splitType,
    required Map<String, double> splitValues,
    required int userCount,
  }) {
    switch (splitType) {
      case SplitType.equal:
        return true; // No validation needed for equal split

      case SplitType.percentage:
        final total = splitValues.values.fold<double>(0, (sum, val) => sum + val);
        if ((total - 100).abs() > 0.01) {
          throw ArgumentError(
            'Percentages must sum to 100%. Current: ${total.toStringAsFixed(1)}%',
          );
        }
        if (splitValues.values.any((v) => v <= 0 || v > 100)) {
          throw ArgumentError('Each percentage must be between 0 and 100');
        }
        return true;

      case SplitType.weightage:
        if (splitValues.values.any((v) => v <= 0)) {
          throw ArgumentError('All weights must be greater than 0');
        }
        return true;
    }
  }
}
