import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.createdBy,
    required super.members,
    required super.createdAt,
    super.currency,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      createdBy: d['createdBy'] as String? ?? '',
      currency: d['currency'] as String? ?? 'USD',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      members: (d['members'] as List<dynamic>? ?? [])
          .map((e) => GroupMemberModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'imageUrl': imageUrl,
        'createdBy': createdBy,
        'currency': currency,
        'createdAt': Timestamp.fromDate(createdAt),
        'members':
            members.map((m) => GroupMemberModel.fromEntity(m).toMap()).toList(),
      };
}

class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.userId,
    required super.role,
    required super.joinedAt,
    super.userName,
    super.userPhotoUrl,
  });

  factory GroupMemberModel.fromMap(Map<String, dynamic> m) => GroupMemberModel(
        userId: m['userId'] as String? ?? '',
        role: m['role'] as String? ?? 'member',
        joinedAt: (m['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  factory GroupMemberModel.fromEntity(GroupMember e) => GroupMemberModel(
        userId: e.userId,
        role: e.role,
        joinedAt: e.joinedAt,
        userName: e.userName,
        userPhotoUrl: e.userPhotoUrl,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'role': role,
        'joinedAt': Timestamp.fromDate(joinedAt),
      };
}

class GroupInviteModel extends GroupInvite {
  const GroupInviteModel({
    required super.id,
    required super.groupId,
    required super.groupName, // ← add
    required super.createdBy,
    required super.expiresAt,
  });

  factory GroupInviteModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupInviteModel(
      id: doc.id,
      groupId: d['groupId'] as String? ?? '',
      groupName: d['groupName'] as String? ?? '', // ← add
      createdBy: d['createdBy'] as String? ?? '',
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'groupName': groupName, // ← add
        'createdBy': createdBy,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
      };
}
