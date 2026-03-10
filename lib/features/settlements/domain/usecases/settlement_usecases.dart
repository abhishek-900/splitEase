import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/settlement_entity.dart';
import '../repositories/settlement_repository.dart';

@lazySingleton
class WatchGroupSettlementsUseCase {
  final SettlementRepository _r;
  WatchGroupSettlementsUseCase(this._r);
  Stream<List<SettlementEntity>> call(String groupId) => _r.watchGroupSettlements(groupId);
}

@lazySingleton
class RecordSettlementUseCase {
  final SettlementRepository _r;
  RecordSettlementUseCase(this._r);
  Future<Either<Failure, SettlementEntity>> call({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    String? note,
  }) => _r.recordSettlement(
    groupId: groupId, fromUserId: fromUserId, toUserId: toUserId,
    amount: amount, currency: currency, note: note,
  );
}
