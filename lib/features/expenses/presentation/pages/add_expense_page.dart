import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expense_bloc.dart';

class AddExpensePage extends StatelessWidget {
  final String groupId;
  const AddExpensePage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    // Own BlocProvider — go_router creates a new route context
    // so parent's ExpenseBloc is not available here.
    return BlocProvider(
      create: (_) => getIt<ExpenseBloc>(),
      child: _AddExpenseView(groupId: groupId),
    );
  }
}

class _AddExpenseView extends StatefulWidget {
  final String groupId;
  const _AddExpenseView({required this.groupId});

  @override
  State<_AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<_AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.food;
  SplitType _splitType = SplitType.equal;
  String? _paidBy;

  final Map<String, TextEditingController> _splitControllers = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _splitControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 600) / 2).clamp(24.0, double.infinity) : 20.0;

    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (ctx, state) {
        if (state is ExpenseOperationSuccess) {
          // Pop back — GroupDetailPage FAB handler will reload
          ctx.pop();
        }
        if (state is ExpenseError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final gState = ctx.read<GroupBloc>().state;
        final group = gState is GroupLoaded
            ? gState.groups.where((g) => g.id == widget.groupId).firstOrNull
            : null;
        final members = group?.members ?? [];

        _paidBy ??= ctx.read<AuthBloc>().state is AuthAuthenticated
            ? (ctx.read<AuthBloc>().state as AuthAuthenticated).user.id
            : null;

        for (final m in members) {
          _splitControllers.putIfAbsent(
              m.userId, () => TextEditingController());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Expense'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ctx.pop(),
            ),
            actions: [
              TextButton(
                onPressed: state is ExpenseLoading
                    ? null
                    : () => _submit(ctx, members),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              children: [
                // ── Amount card ────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: Validators.amount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description ────────────────────────────────────────
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Description (e.g. Dinner, Flights)',
                  ),
                  validator: (v) => Validators.required(v, 'Description'),
                ),
                const SizedBox(height: 16),

                // ── Category ───────────────────────────────────────────
                const _SectionLabel('Category'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExpenseCategory.values
                      .map((cat) => ChoiceChip(
                            label: Text(
                              '${cat.emoji} ${cat.label}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _category == cat,
                            onSelected: (_) => setState(() => _category = cat),
                            selectedColor: cat.color.withOpacity(0.15),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // ── Paid by ────────────────────────────────────────────
                if (members.isNotEmpty) ...[
                  const _SectionLabel('Paid by'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _paidBy,
                    decoration: const InputDecoration(),
                    items: members.map((m) {
                      final label = m.userName?.isNotEmpty == true
                          ? m.userName!
                          : m.displayName;
                      return DropdownMenuItem(
                        value: m.userId,
                        child:
                            Text(label, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _paidBy = v),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Split type ─────────────────────────────────────────
                const _SectionLabel('Split'),
                const SizedBox(height: 8),
                Row(
                  children: SplitType.values.map((t) {
                    final isSelected = _splitType == t;
                    final isLast = t == SplitType.values.last;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _splitType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.neutral100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : AppTheme.neutral200,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(t.icon,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.neutral500),
                                const SizedBox(height: 4),
                                Text(
                                  t.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // ── Per-member split inputs ────────────────────────────
                if (members.isNotEmpty && _splitType != SplitType.equal) ...[
                  const SizedBox(height: 16),
                  _SectionLabel(
                    _splitType == SplitType.percentage
                        ? 'Percentages'
                        : 'Exact amounts',
                  ),
                  const SizedBox(height: 8),
                  ...members.map((m) {
                    final label = m.userName?.isNotEmpty == true
                        ? m.userName!
                        : m.displayName;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: _splitControllers[m.userId],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: _splitType == SplitType.percentage
                                    ? '%'
                                    : '0.00',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 16),

                // ── Note ──────────────────────────────────────────────
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Add a note (optional)',
                  ),
                ),
                const SizedBox(height: 28),

                // ── Submit ────────────────────────────────────────────
                if (state is ExpenseLoading)
                  const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryBlue),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _submit(ctx, members),
                    child: const Text('Save Expense'),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext ctx, List<GroupMember> members) {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());
    ctx.read<ExpenseBloc>().add(AddExpense(
          groupId: widget.groupId,
          title: _titleCtrl.text.trim(),
          amount: amount,
          paidBy: _paidBy ?? '',
          splitType: _splitType,
          splits: _buildSplits(members, amount),
          category: _category,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        ));
  }

  List<SplitShare> _buildSplits(List<GroupMember> members, double total) {
    if (_splitType == SplitType.equal) {
      final each = double.parse((total / members.length).toStringAsFixed(2));
      return members
          .map((m) => SplitShare(userId: m.userId, amount: each))
          .toList();
    }
    if (_splitType == SplitType.percentage) {
      return members.map((m) {
        final pct =
            double.tryParse(_splitControllers[m.userId]?.text ?? '') ?? 0;
        return SplitShare(
          userId: m.userId,
          amount: total * pct / 100,
          percentage: pct,
        );
      }).toList();
    }
    return members.map((m) {
      final amt = double.tryParse(_splitControllers[m.userId]?.text ?? '') ?? 0;
      return SplitShare(userId: m.userId, amount: amt);
    }).toList();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.neutral500,
          letterSpacing: 0.8,
        ),
      );
}
