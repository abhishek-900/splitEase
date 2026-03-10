import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/group_bloc.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _currency = 'INR'; // ← default INR

  static const _currencies = [
    ('INR', 'INR — Indian Rupee', '₹'),
    ('USD', 'USD — US Dollar', '\$'),
    ('EUR', 'EUR — Euro', '€'),
    ('GBP', 'GBP — British Pound', '£'),
    ('JPY', 'JPY — Japanese Yen', '¥'),
    ('CAD', 'CAD — Canadian Dollar', 'CA\$'),
    ('AUD', 'AUD — Australian Dollar', 'AU\$'),
    ('SGD', 'SGD — Singapore Dollar', 'S\$'),
    ('AED', 'AED — UAE Dirham', 'د.إ'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 600;
    final hPad = isWide ? w * 0.25 : 24.0;

    return BlocConsumer<GroupBloc, GroupState>(
      listener: (ctx, state) {
        if (state is GroupLoaded) ctx.pop();
        if (state is GroupError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(
          title: const Text('New Group'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ctx.pop(),
          ),
          actions: [
            TextButton(
              onPressed: state is GroupLoading ? null : () => _submit(ctx),
              child: const Text(
                'Create',
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
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
            children: [
              // ── Avatar placeholder ─────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.group,
                      size: 32, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 28),

              // ── Group name ─────────────────────────────────────────────
              const Text(
                'GROUP NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Trip to Goa, Flatmates…',
                ),
                validator: Validators.groupName,
              ),
              const SizedBox(height: 20),

              // ── Currency ───────────────────────────────────────────────
              const Text(
                'CURRENCY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(),
                items: _currencies
                    .map((c) => DropdownMenuItem(
                          value: c.$1,
                          child: Text('${c.$3}  ${c.$2}',
                              style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _currency = v!),
              ),
              const SizedBox(height: 36),

              // ── Submit ─────────────────────────────────────────────────
              if (state is GroupLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                )
              else
                ElevatedButton(
                  onPressed: () => _submit(ctx),
                  child: const Text('Create Group'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    final authState = ctx.read<AuthBloc>().state;
    final uid = authState is AuthAuthenticated ? authState.user.id : '';
    ctx.read<GroupBloc>().add(
          CreateGroup(
            name: _nameCtrl.text.trim(),
            createdBy: uid,
            currency: _currency,
          ),
        );
  }
}
