import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents how much a specific user owes in an expense
@immutable
class UserSplit extends Equatable {
  const UserSplit({
    required this.userId,
    required this.userName,
    required this.amount,
    required this.splitValue,
  });

  /// ID of the user
  final String userId;

  /// Name of the user (for display purposes)
  final String userName;

  /// Calculated amount this user owes
  final double amount;

  /// The split value used for calculation
  /// - For equal split: 1 (equal share)
  /// - For percentage: percentage value (e.g., 40 for 40%)
  /// - For weightage: weight value (e.g., 2 for weight of 2)
  final double splitValue;

  UserSplit copyWith({
    String? userId,
    String? userName,
    double? amount,
    double? splitValue,
  }) {
    return UserSplit(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      splitValue: splitValue ?? this.splitValue,
    );
  }

  @override
  List<Object?> get props => [userId, userName, amount, splitValue];
}
