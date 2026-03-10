import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/settlement_remote_datasource.dart';

@LazySingleton(as: SettlementRepository)
class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementRemoteDataSource _remote;
  final NetworkInfo                _net;

  SettlementRepositoryImpl(this._remote, this._net);

  @override
  Stream<List<SettlementEntity>> watchGroupSettlements(String groupId) =>
      _remote.watchGroupSettlements(groupId);

  @override
  Future<Either<Failure, SettlementEntity>> recordSettlement({
    required String groupId, required String fromUserId, required String toUserId,
    required double amount, required String currency, String? note,
  }) async {
    if (!await _net.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.recordSettlement(
        groupId: groupId, fromUserId: fromUserId, toUserId: toUserId,
        amount: amount, currency: currency, note: note,
      ));
    } catch (e) {
      return Left(SettleFailure(e.toString()));
    }
  }
}
