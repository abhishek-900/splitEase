import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../bloc/group_bloc.dart';
import '../widgets/expense_list_tile.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExpenseBloc>()..add(LoadGroupExpenses(groupId)),
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  final String groupId;
  const _GroupDetailView({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 680) / 2).clamp(24.0, double.infinity) : 16.0;

    return BlocBuilder<GroupBloc, GroupState>(
      builder: (ctx, gState) {
        final group = gState is GroupLoaded
            ? gState.groups.where((g) => g.id == groupId).firstOrNull
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(group?.name ?? '…'),
            actions: [
              if (group != null)
                IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  tooltip: 'Invite',
                  onPressed: () => ctx.push(AppRoutes.groupInvite(groupId)),
                ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'settle') ctx.push(AppRoutes.settleUp(groupId));
                  if (v == 'delete') {
                    ctx.read<GroupBloc>().add(DeleteGroup(groupId));
                    ctx.pop();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'settle', child: Text('Settle up')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete group',
                        style: TextStyle(color: AppTheme.error)),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              // Push to add expense — ExpenseBloc is in the tree so it's shared
              await ctx.push(AppRoutes.addExpense(groupId));
              // After returning, re-load in case stream missed the update
              if (ctx.mounted) {
                ctx.read<ExpenseBloc>().add(LoadGroupExpenses(groupId));
              }
            },
            backgroundColor: AppTheme.primaryBlue,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Expense',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: group == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : CustomScrollView(
                  slivers: [
                    // ── Members section ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MEMBERS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.neutral500,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _MemberChips(members: group.members),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            const Text(
                              'EXPENSES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.neutral500,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    // ── Expenses list ───────────────────────────────────
                    BlocBuilder<ExpenseBloc, ExpenseState>(
                      builder: (ctx, eState) {
                        // Loading or just saved — show spinner
                        if (eState is ExpenseLoading ||
                            eState is ExpenseOperationSuccess) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue),
                            ),
                          );
                        }

                        if (eState is ExpenseError) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  eState.message,
                                  style: const TextStyle(
                                      color: AppTheme.error, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }

                        if (eState is ExpenseLoaded &&
                            eState.expenses.isEmpty) {
                          return const SliverFillRemaining(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 48, color: AppTheme.neutral300),
                                SizedBox(height: 14),
                                Text(
                                  'No expenses yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.neutral400,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tap + Add Expense to get started',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (eState is ExpenseLoaded) {
                          return SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 120),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ExpenseListTile(
                                    expense: eState.expenses[i],
                                    currency: group.currency,
                                    onTap: () => ctx.push(
                                      AppRoutes.expenseDetail(
                                        groupId,
                                        eState.expenses[i].id,
                                      ),
                                    ),
                                  ),
                                ),
                                childCount: eState.expenses.length,
                              ),
                            ),
                          );
                        }

                        return const SliverToBoxAdapter(
                            child: SizedBox.shrink());
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ─── Member chips ─────────────────────────────────────────────────────────────

class _MemberChips extends StatelessWidget {
  final List members;
  const _MemberChips({required this.members});

  Color _color(String name) {
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
    return colors[name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: members.map<Widget>((m) {
        final name =
            (m.userName?.isNotEmpty == true ? m.userName : m.userId) as String;
        final color = _color(name);
        final init = name.isNotEmpty ? name[0].toUpperCase() : '?';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  init,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name.split(' ').first,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if ((m.role as String) == 'admin') ...[
                const SizedBox(width: 4),
                Icon(Icons.star_rounded, size: 11, color: color),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
