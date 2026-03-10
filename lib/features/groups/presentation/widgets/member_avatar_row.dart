import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/group_entity.dart';

class MemberAvatarRow extends StatelessWidget {
  final List<GroupMember> members;
  final int maxVisible;
  final double size;

  const MemberAvatarRow({
    super.key,
    required this.members,
    this.maxVisible = 4,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final visible = members.take(maxVisible).toList();
    final overflow = members.length - maxVisible;
    final count = visible.length + (overflow > 0 ? 1 : 0);

    if (count == 0) return const SizedBox.shrink();

    // Calculate exact width needed for stacked avatars
    final stackWidth = size + (count - 1) * (size * 0.7);

    return SizedBox(
      width: stackWidth,
      height: size,
      child: Stack(
        children: [
          ...List.generate(visible.length, (i) {
            return Positioned(
              left: i * (size * 0.7),
              child: _MemberAvatar(member: visible[i], size: size),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: visible.length * (size * 0.7),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppTheme.neutral200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutral600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Single avatar ────────────────────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  final GroupMember member;
  final double size;

  const _MemberAvatar({required this.member, required this.size});

  Color _colorFromName(String name) {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFFF97316),
      Color(0xFF14B8A6),
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
    ];
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFromName(member.displayName);
    final initial = member.initial;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        color: color.withValues(alpha: 0.15),
      ),
      child: member.userPhotoUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: member.userPhotoUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _Initials(
                  initial: initial,
                  color: color,
                  size: size,
                ),
              ),
            )
          : _Initials(initial: initial, color: color, size: size),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initial;
  final Color color;
  final double size;

  const _Initials({
    required this.initial,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
