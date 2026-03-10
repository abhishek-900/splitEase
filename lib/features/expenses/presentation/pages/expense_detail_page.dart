import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../bloc/expense_bloc.dart';

class ExpenseDetailPage extends StatelessWidget {
  final String groupId;
  final String expenseId;
  const ExpenseDetailPage(
      {super.key, required this.groupId, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExpenseBloc>()..add(LoadGroupExpenses(groupId)),
      child: _ExpenseDetailView(groupId: groupId, expenseId: expenseId),
    );
  }
}

class _ExpenseDetailView extends StatelessWidget {
  final String groupId;
  final String expenseId;
  const _ExpenseDetailView({required this.groupId, required this.expenseId});

  /// Resolve a userId → display name using group members list
  String _nameFor(String userId, List<GroupMember> members) {
    final match = members.where((m) => m.userId == userId).firstOrNull;
    if (match == null) return userId;
    return match.userName?.isNotEmpty == true
        ? match.userName!
        : match.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 600) / 2).clamp(24.0, double.infinity) : 20.0;

    // Get members from GroupBloc (already loaded)
    final gState = context.read<GroupBloc>().state;
    final members = gState is GroupLoaded
        ? (gState.groups.where((g) => g.id == groupId).firstOrNull?.members ??
            <GroupMember>[])
        : <GroupMember>[];

    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (ctx, state) {
        final expense = state is ExpenseLoaded
            ? state.expenses.where((e) => e.id == expenseId).firstOrNull
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(expense?.title ?? 'Expense'),
            actions: [
              if (expense != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                  tooltip: 'Delete',
                  onPressed: () {
                    ctx.read<ExpenseBloc>().add(
                          DeleteExpense(expenseId: expenseId, groupId: groupId),
                        );
                    ctx.pop();
                  },
                ),
            ],
          ),
          body: expense == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header card ─────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text(expense.category.emoji,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 10),
                            Text(
                              expense.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyUtils.format(expense.amount),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(AppDateUtils.full(expense.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Info rows ────────────────────────────────────
                      _InfoRow(
                        label: 'Paid by',
                        value: _nameFor(expense.paidBy, members),
                      ),
                      _InfoRow(
                        label: 'Split type',
                        value: expense.splitType.label,
                      ),
                      _InfoRow(
                        label: 'Category',
                        value:
                            '${expense.category.emoji} ${expense.category.label}',
                      ),
                      if (expense.note != null && expense.note!.isNotEmpty)
                        _InfoRow(label: 'Note', value: expense.note!),

                      const SizedBox(height: 20),
                      const Text(
                        'Splits',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Splits list ──────────────────────────────────
                      ...expense.splits.map((s) {
                        final name = _nameFor(s.userId, members);
                        final initial =
                            name.isNotEmpty ? name[0].toUpperCase() : '?';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    AppTheme.primaryBlue.withOpacity(0.1),
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyUtils.format(
                                  s.amount,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.neutral900,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // ── Receipt ──────────────────────────────────────
                      if (expense.receiptUrl != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Receipt',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: expense.receiptUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.neutral500)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral900,
              ),
            ),
          ],
        ),
      );
}
