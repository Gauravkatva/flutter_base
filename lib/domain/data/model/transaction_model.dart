import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents a simplified transaction for settlement
@immutable
class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    this.isSettled = false,
  });

  /// Unique identifier for the transaction
  final String id;

  /// ID of user who needs to pay
  final String fromUserId;

  /// Name of user who needs to pay
  final String fromUserName;

  /// ID of user who should receive payment
  final String toUserId;

  /// Name of user who should receive payment
  final String toUserName;

  /// Amount to be paid
  final double amount;

  /// Whether this transaction has been settled
  final bool isSettled;

  /// Get formatted amount for display
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';

  /// Get transaction description
  String get description => '$fromUserName pays $toUserName $formattedAmount';

  TransactionModel copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    double? amount,
    bool? isSettled,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  TransactionModel markAsSettled() {
    return copyWith(isSettled: true);
  }

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        fromUserName,
        toUserId,
        toUserName,
        amount,
        isSettled,
      ];
}
