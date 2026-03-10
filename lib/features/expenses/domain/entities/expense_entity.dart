import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SplitType {
  equal('Equal', Icons.people),
  percentage('Percentage', Icons.percent),
  exact('Exact', Icons.attach_money);

  final String label;
  final IconData icon;
  const SplitType(this.label, this.icon);
}

enum ExpenseCategory {
  food('Food',         '🍽️', Color(0xFFF97316)),
  transport('Travel',  '✈️', Color(0xFF3B82F6)),
  accommodation('Stay','🏠', Color(0xFF8B5CF6)),
  entertainment('Fun', '🎉', Color(0xFFEC4899)),
  shopping('Shopping', '🛍️', Color(0xFF14B8A6)),
  groceries('Groceries','🛒',Color(0xFF22C55E)),
  utilities('Utilities','⚡', Color(0xFFEAB308)),
  health('Health',     '💊', Color(0xFFEF4444)),
  sports('Sports',     '⚽', Color(0xFF06B6D4)),
  other('Other',       '📦', Color(0xFF6B7280));

  final String label;
  final String emoji;
  final Color  color;
  const ExpenseCategory(this.label, this.emoji, this.color);
}

class ExpenseEntity extends Equatable {
  final String          id;
  final String          groupId;
  final String          title;
  final double          amount;
  final String          paidBy;
  final SplitType       splitType;
  final List<SplitShare> splits;
  final ExpenseCategory category;
  final String?         note;
  final String?         receiptUrl;
  final DateTime        createdAt;
  final DateTime?       updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
    required this.category,
    this.note,
    this.receiptUrl,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, groupId, title, amount, paidBy, splitType, createdAt];
}

class SplitShare extends Equatable {
  final String userId;
  final double amount;
  final double? percentage;

  const SplitShare({required this.userId, required this.amount, this.percentage});

  @override
  List<Object?> get props => [userId, amount];
}
