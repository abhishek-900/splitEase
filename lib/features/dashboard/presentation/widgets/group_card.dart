import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/widgets/member_avatar_row.dart';

class GroupCard extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onTap;

  const GroupCard({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final n = group.members.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.neutral200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Group initial icon ──────────────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name + meta ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Group name
                  Text(
                    group.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Avatars + meta info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bounded width for avatar stack
                      SizedBox(
                        width: 22 +
                            (n.clamp(0, 4) - 1) * 15.4 +
                            (n > 4 ? 15.4 : 0),
                        height: 22,
                        child: MemberAvatarRow(
                          members: group.members,
                          maxVisible: 4,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '$n ${n == 1 ? 'member' : 'members'}'
                          ' · ${group.currency}'
                          ' · ${AppDateUtils.relative(group.createdAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.neutral400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Chevron ─────────────────────────────────────────────────
            const Icon(Icons.chevron_right,
                color: AppTheme.neutral400, size: 18),
          ],
        ),
      ),
    );
  }
}
