import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Stream<List<SettlementEntity>> watchGroupSettlements(String groupId);
  Future<Either<Failure, SettlementEntity>> recordSettlement({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    String? note,
  });
}
