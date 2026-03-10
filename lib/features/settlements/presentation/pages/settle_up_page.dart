import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/debt_simplifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/domain/usecases/group_usecases.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../domain/usecases/settlement_usecases.dart';

class SettleUpPage extends StatefulWidget {
  final String groupId;
  const SettleUpPage({super.key, required this.groupId});
  @override
  State<SettleUpPage> createState() => _SettleUpPageState();
}

class _SettleUpPageState extends State<SettleUpPage> {
  List<Transaction> _transactions = [];
  GroupEntity? _group;
  bool _loading = true;
  String? _error;
  String? _recordingFor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await getIt<GetGroupBalancesUseCase>()(widget.groupId);
    res.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (balances) {
        final map = {for (final b in balances) b.userId: b.balance};
        _transactions = DebtSimplifier.simplify(map);
        final gState = context.read<GroupBloc>().state;
        _group = gState is GroupLoaded
            ? gState.groups.where((g) => g.id == widget.groupId).firstOrNull
            : null;
        setState(() => _loading = false);
      },
    );
  }

  Future<void> _recordPayment(Transaction txn) async {
    final key = '${txn.from}-${txn.to}';
    setState(() => _recordingFor = key);
    await getIt<RecordSettlementUseCase>()(
      groupId: widget.groupId,
      fromUserId: txn.from,
      toUserId: txn.to,
      amount: txn.amount,
      currency: _group?.currency ?? 'INR',
    );
    setState(() => _recordingFor = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settlement recorded ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.success,
        ),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 680) / 2).clamp(24.0, double.infinity) : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: const TextStyle(color: AppTheme.error),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _transactions.isEmpty
                  ? const _AllSettledView()
                  : ListView(
                      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                      children: [
                        const Text(
                          'Suggested payments',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'These payments will settle all debts with the fewest transactions.',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.neutral500),
                        ),
                        const SizedBox(height: 20),
                        ..._transactions.map((txn) {
                          final key = '${txn.from}-${txn.to}';
                          final recording = _recordingFor == key;
                          final members = _group?.members ?? [];
                          final fromName = members
                                  .where((m) => m.userId == txn.from)
                                  .firstOrNull
                                  ?.displayName ??
                              txn.from;
                          final toName = members
                                  .where((m) => m.userId == txn.to)
                                  .firstOrNull
                                  ?.displayName ??
                              txn.to;
                          return _TransactionCard(
                            fromName: fromName,
                            toName: toName,
                            amount: txn.amount,
                            currency: _group?.currency ?? 'INR',
                            recording: recording,
                            onRecord: () => _recordPayment(txn),
                          );
                        }),
                      ],
                    ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final String fromName;
  final String toName;
  final double amount;
  final String currency;
  final bool recording;
  final VoidCallback onRecord;

  const _TransactionCard({
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.currency,
    required this.recording,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar from
          _Avatar(name: fromName, color: AppTheme.error),
          const SizedBox(width: 10),

          // Arrow
          const Icon(Icons.arrow_forward_rounded,
              size: 16, color: AppTheme.neutral400),
          const SizedBox(width: 10),

          // Avatar to
          _Avatar(name: toName, color: AppTheme.success),
          const SizedBox(width: 12),

          // Names + amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.neutral900),
                    children: [
                      TextSpan(
                          text: fromName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: ' pays '),
                      TextSpan(
                          text: toName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyUtils.format(amount, code: currency),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Record button
          if (recording)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.primaryBlue),
            )
          else
            TextButton(
              onPressed: onRecord,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Mark paid',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;
  const _Avatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final init = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.15),
      child: Text(init,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─── All Settled ──────────────────────────────────────────────────────────────

class _AllSettledView extends StatelessWidget {
  const _AllSettledView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 44, color: AppTheme.success),
            ),
            const SizedBox(height: 20),
            const Text(
              'All settled up! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'No outstanding debts in this group.',
              style: TextStyle(fontSize: 15, color: AppTheme.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
