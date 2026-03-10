import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';
import '../models/group_model.dart';

@LazySingleton(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remote;
  final NetworkInfo _net;
  final FirebaseFirestore _db;

  GroupRepositoryImpl(this._remote, this._net, this._db);

  @override
  Stream<List<GroupEntity>> watchUserGroups(String userId) =>
      _remote.watchUserGroups(userId);

  @override
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    required String createdBy,
    String? imageUrl,
    String currency = 'USD',
  }) async {
    try {
      return Right(await _remote.createGroup(
          name: name,
          createdBy: createdBy,
          imageUrl: imageUrl,
          currency: currency));
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroup(String groupId) async {
    try {
      return Right(await _remote.getGroup(groupId));
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> updateGroup({
    required String groupId,
    String? name,
    String? imageUrl,
    String? currency,
  }) async {
    try {
      return Right(await _remote.updateGroup(
          groupId: groupId,
          name: name,
          imageUrl: imageUrl,
          currency: currency));
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGroup(String groupId) async {
    try {
      await _remote.deleteGroup(groupId);
      return const Right(unit);
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> addMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    try {
      await _remote.addMember(groupId: groupId, userId: userId, role: role);
      return const Right(unit);
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _remote.removeMember(groupId: groupId, userId: userId);
      return const Right(unit);
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GroupInvite>> createInvite({
    required String groupId,
    required String createdBy,
  }) async {
    try {
      return Right(
          await _remote.createInvite(groupId: groupId, createdBy: createdBy));
    } on InviteException catch (e) {
      return Left(InviteFailure(e.message));
    }
  }

  // No network check — connectivity_plus hangs on mobile web Safari.
  // Datasource has 10-second timeouts on every Firestore call.
  @override
  Future<Either<Failure, GroupEntity>> joinViaInvite({
    required String inviteId,
    required String userId,
  }) async {
    try {
      return Right(
          await _remote.joinViaInvite(inviteId: inviteId, userId: userId));
    } on InviteException catch (e) {
      return Left(InviteFailure(e.message));
    } on GroupException catch (e) {
      return Left(GroupFailure(e.message));
    }
  }

  // ── Real balance calculation ───────────────────────────────────────────────
  // Fetches all expenses + settlements for the group and computes
  // net balance per member. Positive = owed to user. Negative = user owes.
  @override
  Future<Either<Failure, List<MemberBalance>>> getGroupBalances(
      String groupId) async {
    try {
      // 1. Load group members
      final groupDoc =
          await _db.collection(AppConstants.colGroups).doc(groupId).get();
      if (!groupDoc.exists) return const Left(GroupFailure('Group not found'));
      final group = GroupModel.fromFirestore(groupDoc);

      // 2. Initialise balance map for every member
      final Map<String, double> bal = {
        for (final m in group.members) m.userId: 0.0,
      };

      // 3. Process expenses
      final expSnap = await _db
          .collection(AppConstants.colExpenses)
          .where('groupId', isEqualTo: groupId)
          .get();

      for (final doc in expSnap.docs) {
        final data = doc.data();
        final paidBy = data['paidBy'] as String? ?? '';
        final splits = (data['splits'] as List? ?? []);

        for (final s in splits) {
          final uid = s['userId'] as String? ?? '';
          final amount = (s['amount'] as num?)?.toDouble() ?? 0.0;
          if (uid == paidBy || uid.isEmpty) continue;

          // paidBy is owed `amount` by `uid`
          bal[paidBy] = (bal[paidBy] ?? 0) + amount;
          bal[uid] = (bal[uid] ?? 0) - amount;
        }
      }

      // 4. Process settlements (reduce debts)
      final settleSnap = await _db
          .collection(AppConstants.colSettlements)
          .where('groupId', isEqualTo: groupId)
          .get();

      for (final doc in settleSnap.docs) {
        final data = doc.data();
        final from = data['fromUserId'] as String? ?? '';
        final to = data['toUserId'] as String? ?? '';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

        // from paid to → from's debt decreases, to's credit decreases
        bal[from] = (bal[from] ?? 0) + amount;
        bal[to] = (bal[to] ?? 0) - amount;
      }

      // 5. Build result
      final result = group.members.map((m) {
        final b = double.parse((bal[m.userId] ?? 0).toStringAsFixed(2));
        return MemberBalance(
          userId: m.userId,
          userName: m.userName ?? m.userId,
          photoUrl: m.userPhotoUrl,
          balance: b,
        );
      }).toList();

      return Right(result);
    } catch (e) {
      return Left(GroupFailure(e.toString()));
    }
  }
}
