import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.groupId,
    required super.title,
    required super.amount,
    required super.paidBy,
    required super.splitType,
    required super.splits,
    required super.category,
    super.note,
    super.receiptUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id:         doc.id,
      groupId:    d['groupId']    as String? ?? '',
      title:      d['title']      as String? ?? '',
      amount:     (d['amount']    as num?)?.toDouble() ?? 0.0,
      paidBy:     d['paidBy']     as String? ?? '',
      note:       d['note']       as String?,
      receiptUrl: d['receiptUrl'] as String?,
      splitType:  SplitType.values.firstWhere(
          (e) => e.name == (d['splitType'] as String? ?? 'equal'),
          orElse: () => SplitType.equal),
      category: ExpenseCategory.values.firstWhere(
          (e) => e.name == (d['category'] as String? ?? 'other'),
          orElse: () => ExpenseCategory.other),
      splits: (d['splits'] as List<dynamic>? ?? [])
          .map((e) => SplitShareModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId':    groupId,
    'title':      title,
    'amount':     amount,
    'paidBy':     paidBy,
    'splitType':  splitType.name,
    'category':   category.name,
    'note':       note,
    'receiptUrl': receiptUrl,
    'splits':     splits.map((s) => SplitShareModel.fromEntity(s).toMap()).toList(),
    'createdAt':  Timestamp.fromDate(createdAt),
    'updatedAt':  updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };
}

class SplitShareModel extends SplitShare {
  const SplitShareModel({required super.userId, required super.amount, super.percentage});

  factory SplitShareModel.fromMap(Map<String, dynamic> m) => SplitShareModel(
    userId:     m['userId']     as String? ?? '',
    amount:     (m['amount']    as num?)?.toDouble() ?? 0.0,
    percentage: (m['percentage'] as num?)?.toDouble(),
  );

  factory SplitShareModel.fromEntity(SplitShare e) =>
      SplitShareModel(userId: e.userId, amount: e.amount, percentage: e.percentage);

  Map<String, dynamic> toMap() => {
    'userId':     userId,
    'amount':     amount,
    'percentage': percentage,
  };
}
