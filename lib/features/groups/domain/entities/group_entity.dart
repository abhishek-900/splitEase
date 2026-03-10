import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String createdBy;
  final List<GroupMember> members;
  final DateTime createdAt;
  final String currency;

  const GroupEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.currency = 'USD',
  });

  bool isAdmin(String uid) =>
      members.any((m) => m.userId == uid && m.role == 'admin');
  bool isMember(String uid) => members.any((m) => m.userId == uid);

  @override
  List<Object?> get props =>
      [id, name, createdBy, members, createdAt, currency];
}

class GroupMember extends Equatable {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? userName;
  final String? userPhotoUrl;

  const GroupMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
    this.userPhotoUrl,
  });

  bool get isAdmin => role == 'admin';
  String get displayName => userName ?? userId;
  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [userId, role, joinedAt];
}

class GroupInvite extends Equatable {
  final String id;
  final String groupId;
  final String groupName; // ← add this
  final String createdBy;
  final DateTime expiresAt;

  const GroupInvite({
    required this.id,
    required this.groupId,
    required this.groupName, // ← add this
    required this.createdBy,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, groupId, expiresAt];
}

class MemberBalance extends Equatable {
  final String userId;
  final String userName;
  final String? photoUrl;
  final double balance; // + = owed to user, - = user owes

  const MemberBalance({
    required this.userId,
    required this.userName,
    this.photoUrl,
    required this.balance,
  });

  bool get isOwed => balance > 0;
  bool get owes => balance < 0;
  bool get settled => balance.abs() < 0.01;

  @override
  List<Object?> get props => [userId, balance];
}
