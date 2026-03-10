import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';

abstract class GroupRepository {
  Stream<List<GroupEntity>> watchUserGroups(String userId);
  Future<Either<Failure, GroupEntity>>   createGroup({required String name, required String createdBy, String? imageUrl, String currency});
  Future<Either<Failure, GroupEntity>>   getGroup(String groupId);
  Future<Either<Failure, GroupEntity>>   updateGroup({required String groupId, String? name, String? imageUrl, String? currency});
  Future<Either<Failure, Unit>>          deleteGroup(String groupId);
  Future<Either<Failure, Unit>>          addMember({required String groupId, required String userId, String role});
  Future<Either<Failure, Unit>>          removeMember({required String groupId, required String userId});
  Future<Either<Failure, GroupInvite>>   createInvite({required String groupId, required String createdBy});
  Future<Either<Failure, GroupEntity>>   joinViaInvite({required String inviteId, required String userId});
  Future<Either<Failure, List<MemberBalance>>> getGroupBalances(String groupId);
}
