import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/settlement_entity.dart';

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.groupId,
    required super.fromUserId,
    required super.toUserId,
    required super.amount,
    required super.currency,
    super.note,
    required super.settledAt,
  });

  factory SettlementModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SettlementModel(
      id:         doc.id,
      groupId:    d['groupId']    as String? ?? '',
      fromUserId: d['fromUserId'] as String? ?? '',
      toUserId:   d['toUserId']   as String? ?? '',
      amount:     (d['amount']    as num?)?.toDouble() ?? 0.0,
      currency:   d['currency']   as String? ?? 'USD',
      note:       d['note']       as String?,
      settledAt:  (d['settledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId':    groupId,
    'fromUserId': fromUserId,
    'toUserId':   toUserId,
    'amount':     amount,
    'currency':   currency,
    'note':       note,
    'settledAt':  Timestamp.fromDate(settledAt),
    'createdAt':  FieldValue.serverTimestamp(),
  };
}
