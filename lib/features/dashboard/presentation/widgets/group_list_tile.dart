import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../groups/domain/entities/group_entity.dart';

class GroupListTile extends StatelessWidget {
  final GroupEntity group;
  final String currentUserId;
  final VoidCallback onTap;

  const GroupListTile({
    super.key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual balance from BalanceBloc
    const balance = 34.50;
    const isOwed = balance > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.neutral200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Group Avatar
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: group.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.network(
                        group.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : 'G',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 14.w),
            // Group Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${group.members.length} members • ${AppDateUtils.relative(group.createdAt)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyUtils.format(balance.abs()),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: isOwed ? AppTheme.success : AppTheme.error,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isOwed ? 'you are owed' : 'you owe',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isOwed ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
