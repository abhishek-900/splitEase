import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/group_model.dart';

abstract class GroupRemoteDataSource {
  Stream<List<GroupModel>> watchUserGroups(String userId);
  Future<GroupModel> createGroup({
    required String name,
    required String createdBy,
    String? imageUrl,
    String currency,
  });
  Future<GroupModel> getGroup(String groupId);
  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? imageUrl,
    String? currency,
  });
  Future<void> deleteGroup(String groupId);
  Future<void> addMember({
    required String groupId,
    required String userId,
    String role,
  });
  Future<void> removeMember({
    required String groupId,
    required String userId,
  });
  Future<GroupInviteModel> createInvite({
    required String groupId,
    required String createdBy,
  });
  Future<GroupModel> joinViaInvite({
    required String inviteId,
    required String userId,
  });
}

@LazySingleton(as: GroupRemoteDataSource)
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  GroupRemoteDataSourceImpl(this._db);

  CollectionReference get _groups => _db.collection(AppConstants.colGroups);
  CollectionReference get _invites => _db.collection(AppConstants.colInvites);
  CollectionReference get _users => _db.collection(AppConstants.colUsers);

  @override
  Stream<List<GroupModel>> watchUserGroups(String userId) {
    _repairLegacyGroups(userId);
    return _groups
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .asyncMap((snap) async {
      final result = <GroupModel>[];
      for (final doc in snap.docs) {
        result.add(await _enrichMembers(GroupModel.fromFirestore(doc)));
      }
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    });
  }

  Future<void> _repairLegacyGroups(String userId) async {
    try {
      final byCreator =
          await _groups.where('createdBy', isEqualTo: userId).get();
      for (final doc in byCreator.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final memberIds = List<String>.from(data['memberIds'] as List? ?? []);
        if (!memberIds.contains(userId)) {
          final members = List<Map>.from(data['members'] as List? ?? []);
          final ids = members
              .map((m) => m['userId'] as String?)
              .whereType<String>()
              .toList();
          if (ids.isEmpty) ids.add(userId);
          await _groups.doc(doc.id).update({'memberIds': ids});
        }
      }
    } catch (_) {}
  }

  Future<GroupModel> _enrichMembers(GroupModel group) async {
    final enriched = <GroupMemberModel>[];
    for (final m in group.members) {
      try {
        final doc = await _users.doc(m.userId).get();
        if (doc.exists) {
          final d = doc.data() as Map<String, dynamic>;
          enriched.add(GroupMemberModel(
            userId: m.userId,
            role: m.role,
            joinedAt: m.joinedAt,
            userName: d['name'] as String?,
            userPhotoUrl: d['photoUrl'] as String?,
          ));
          continue;
        }
      } catch (_) {}
      enriched.add(GroupMemberModel.fromEntity(m));
    }
    return GroupModel(
      id: group.id,
      name: group.name,
      imageUrl: group.imageUrl,
      createdBy: group.createdBy,
      currency: group.currency,
      createdAt: group.createdAt,
      members: enriched,
    );
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String createdBy,
    String? imageUrl,
    String currency = 'INR',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final model = GroupModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      createdBy: createdBy,
      currency: currency,
      createdAt: now,
      members: [
        GroupMemberModel(userId: createdBy, role: 'admin', joinedAt: now),
      ],
    );
    final data = model.toMap();
    data['memberIds'] = [createdBy];
    await _groups.doc(id).set(data);
    return model;
  }

  @override
  Future<GroupModel> getGroup(String groupId) async {
    final doc = await _groups.doc(groupId).get();
    if (!doc.exists) throw const GroupException('Group not found');
    return _enrichMembers(GroupModel.fromFirestore(doc));
  }

  @override
  Future<GroupModel> updateGroup({
    required String groupId,
    String? name,
    String? imageUrl,
    String? currency,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (currency != null) data['currency'] = currency;
    if (data.isNotEmpty) await _groups.doc(groupId).update(data);
    return getGroup(groupId);
  }

  @override
  Future<void> deleteGroup(String groupId) => _groups.doc(groupId).delete();

  @override
  Future<void> addMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    await _groups.doc(groupId).update({
      'members': FieldValue.arrayUnion([
        {
          'userId': userId,
          'role': role,
          'joinedAt': Timestamp.now(),
        }
      ]),
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    final doc = await _groups.doc(groupId).get();
    final g = GroupModel.fromFirestore(doc);
    final kept = g.members.where((m) => m.userId != userId).toList();
    await _groups.doc(groupId).update({
      'members':
          kept.map((m) => GroupMemberModel.fromEntity(m).toMap()).toList(),
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<GroupInviteModel> createInvite({
    required String groupId,
    required String createdBy,
  }) async {
    final groupDoc = await _groups.doc(groupId).get();
    final groupName = groupDoc.exists
        ? (groupDoc.data() as Map<String, dynamic>)['name'] as String? ?? ''
        : '';
    final id = _uuid.v4();
    final expires = DateTime.now()
        .add(const Duration(hours: AppConstants.inviteExpiryHours));
    final model = GroupInviteModel(
      id: id,
      groupId: groupId,
      groupName: groupName,
      createdBy: createdBy,
      expiresAt: expires,
    );
    await _invites.doc(id).set(model.toMap());
    return model;
  }

  // ── Join via invite ────────────────────────────────────────────────────────
  // IMPORTANT: Does NOT call getGroup/_enrichMembers after joining —
  // that causes infinite loading due to sequential user doc lookups.
  // Returns a minimal GroupModel directly from the group doc.
  @override
  Future<GroupModel> joinViaInvite({
    required String inviteId,
    required String userId,
  }) async {
    final inviteDoc = await _invites.doc(inviteId).get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw const InviteException('Request timed out'));
    if (!inviteDoc.exists) throw const InviteException('Invite not found');

    final invite = GroupInviteModel.fromFirestore(inviteDoc);
    if (invite.isExpired) throw const InviteException('Invite has expired');

    final groupDoc = await _groups.doc(invite.groupId).get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw const GroupException('Request timed out'));
    if (!groupDoc.exists) throw const GroupException('Group not found');

    final data = groupDoc.data() as Map<String, dynamic>;
    final memberIds = List<String>.from(data['memberIds'] as List? ?? []);

    if (!memberIds.contains(userId)) {
      await addMember(groupId: invite.groupId, userId: userId).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw const GroupException('Request timed out'));
    }

    // Return directly — NO getGroup/_enrichMembers call
    return GroupModel.fromFirestore(groupDoc);
  }
}
