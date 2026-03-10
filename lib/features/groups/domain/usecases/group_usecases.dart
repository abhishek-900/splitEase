import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

@lazySingleton
class WatchUserGroupsUseCase {
  final GroupRepository _r;
  WatchUserGroupsUseCase(this._r);
  Stream<List<GroupEntity>> call(String uid) => _r.watchUserGroups(uid);
}

@lazySingleton
class CreateGroupUseCase {
  final GroupRepository _r;
  CreateGroupUseCase(this._r);
  Future<Either<Failure, GroupEntity>> call({
    required String name,
    required String createdBy,
    String? imageUrl,
    String currency = 'USD',
  }) => _r.createGroup(name: name, createdBy: createdBy, imageUrl: imageUrl, currency: currency);
}

@lazySingleton
class GetGroupUseCase {
  final GroupRepository _r;
  GetGroupUseCase(this._r);
  Future<Either<Failure, GroupEntity>> call(String id) => _r.getGroup(id);
}

@lazySingleton
class UpdateGroupUseCase {
  final GroupRepository _r;
  UpdateGroupUseCase(this._r);
  Future<Either<Failure, GroupEntity>> call({required String groupId, String? name, String? imageUrl, String? currency}) =>
      _r.updateGroup(groupId: groupId, name: name, imageUrl: imageUrl, currency: currency);
}

@lazySingleton
class DeleteGroupUseCase {
  final GroupRepository _r;
  DeleteGroupUseCase(this._r);
  Future<Either<Failure, Unit>> call(String id) => _r.deleteGroup(id);
}

@lazySingleton
class AddMemberUseCase {
  final GroupRepository _r;
  AddMemberUseCase(this._r);
  Future<Either<Failure, Unit>> call({required String groupId, required String userId, String role = 'member'}) =>
      _r.addMember(groupId: groupId, userId: userId, role: role);
}

@lazySingleton
class RemoveMemberUseCase {
  final GroupRepository _r;
  RemoveMemberUseCase(this._r);
  Future<Either<Failure, Unit>> call({required String groupId, required String userId}) =>
      _r.removeMember(groupId: groupId, userId: userId);
}

@lazySingleton
class CreateInviteUseCase {
  final GroupRepository _r;
  CreateInviteUseCase(this._r);
  Future<Either<Failure, GroupInvite>> call({required String groupId, required String createdBy}) =>
      _r.createInvite(groupId: groupId, createdBy: createdBy);
}

@lazySingleton
class JoinViaInviteUseCase {
  final GroupRepository _r;
  JoinViaInviteUseCase(this._r);
  Future<Either<Failure, GroupEntity>> call({required String inviteId, required String userId}) =>
      _r.joinViaInvite(inviteId: inviteId, userId: userId);
}

@lazySingleton
class GetGroupBalancesUseCase {
  final GroupRepository _r;
  GetGroupBalancesUseCase(this._r);
  Future<Either<Failure, List<MemberBalance>>> call(String groupId) => _r.getGroupBalances(groupId);
}
