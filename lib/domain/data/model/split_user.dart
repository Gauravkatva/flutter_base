import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a user in the SplitWise group
@immutable
class SplitUser extends Equatable {
  const SplitUser({
    required this.id,
    required this.name,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final Color avatarColor;

  /// Get initials for avatar display
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  SplitUser copyWith({
    String? id,
    String? name,
    Color? avatarColor,
  }) {
    return SplitUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  @override
  List<Object?> get props => [id, name, avatarColor];
}
