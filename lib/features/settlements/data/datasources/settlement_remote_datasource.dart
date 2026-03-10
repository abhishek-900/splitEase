import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/settlement_model.dart';

abstract class SettlementRemoteDataSource {
  Stream<List<SettlementModel>> watchGroupSettlements(String groupId);
  Future<SettlementModel> recordSettlement({
    required String groupId, required String fromUserId, required String toUserId,
    required double amount, required String currency, String? note,
  });
}

@LazySingleton(as: SettlementRemoteDataSource)
class SettlementRemoteDataSourceImpl implements SettlementRemoteDataSource {
  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  SettlementRemoteDataSourceImpl(this._db);

  CollectionReference get _col => _db.collection(AppConstants.colSettlements);

  @override
  Stream<List<SettlementModel>> watchGroupSettlements(String groupId) {
    return _col
        .where('groupId', isEqualTo: groupId)
        .orderBy('settledAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SettlementModel.fromFirestore(d)).toList());
  }

  @override
  Future<SettlementModel> recordSettlement({
    required String groupId, required String fromUserId, required String toUserId,
    required double amount, required String currency, String? note,
  }) async {
    final id    = _uuid.v4();
    final model = SettlementModel(
      id: id, groupId: groupId, fromUserId: fromUserId, toUserId: toUserId,
      amount: amount, currency: currency, note: note, settledAt: DateTime.now(),
    );
    await _col.doc(id).set(model.toMap());
    return model;
  }
}
