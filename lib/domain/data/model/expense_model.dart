import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:my_appp/domain/data/model/split_type.dart';
import 'package:my_appp/domain/data/model/split_user.dart';
import 'package:my_appp/domain/data/model/user_split.dart';

/// Represents an expense in the SplitWise application
@immutable
class ExpenseModel extends Equatable {
  const ExpenseModel({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
    required this.date,
    this.category,
  });

  /// Unique identifier for the expense
  final String id;

  /// Description of the expense
  final String description;

  /// Total amount of the expense
  final double totalAmount;

  /// User who paid for this expense
  final SplitUser paidBy;

  /// Type of split used
  final SplitType splitType;

  /// List of splits showing how much each user owes
  final List<UserSplit> splits;

  /// Date when expense was created
  final DateTime date;

  /// Optional category for the expense
  final String? category;

  /// Get formatted amount for display
  String get formattedAmount => '₹${totalAmount.toStringAsFixed(2)}';

  /// Get formatted date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Verify that splits sum to total amount (with small tolerance for rounding)
  bool get isSplitValid {
    final totalSplit = splits.fold<double>(
      0,
      (sum, split) => sum + split.amount,
    );
    return (totalSplit - totalAmount).abs() < 0.01;
  }

  ExpenseModel copyWith({
    String? id,
    String? description,
    double? totalAmount,
    SplitUser? paidBy,
    SplitType? splitType,
    List<UserSplit>? splits,
    DateTime? date,
    String? category,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paidBy: paidBy ?? this.paidBy,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        description,
        totalAmount,
        paidBy,
        splitType,
        splits,
        date,
        category,
      ];
}
