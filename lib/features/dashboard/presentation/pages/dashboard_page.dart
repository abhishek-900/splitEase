import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../main.dart' show themeNotifier, toggleAppTheme;
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/group_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<GroupBloc>().add(LoadUserGroups(auth.user.id));
    } else {
      context.read<AuthBloc>().stream.listen((s) {
        if (s is AuthAuthenticated && mounted) {
          context.read<GroupBloc>().add(LoadUserGroups(s.user.id));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          _GroupsTab(user: user),
          _ActivityTab(user: user),
          _ProfileTab(user: user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group, color: AppTheme.primaryBlue),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.createGroup),
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── Groups Tab ───────────────────────────────────────────────────────────────

class _GroupsTab extends StatelessWidget {
  final dynamic user;
  const _GroupsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 680) / 2).clamp(24.0, double.infinity) : 16.0;
    final currency = (user?.defaultCurrency as String?) ?? 'INR';
    final uid = (user?.id as String?) ?? '';

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${(user?.name as String?)?.split(' ').first ?? 'there'} 👋',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            const Text("Here's what's going on",
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.neutral500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Avatar(user: user, radius: 20),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Balance card — listens to BOTH expenses AND settlements
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (ctx, gState) {
                      final groupIds = gState is GroupLoaded
                          ? gState.groups.map((g) => g.id).toList()
                          : <String>[];

                      if (uid.isEmpty) {
                        return BalanceSummaryCard(
                          netBalance: 0,
                          totalOwed: 0,
                          totalOwe: 0,
                          currency: currency,
                        );
                      }

                      return StreamBuilder<BalanceSummary>(
                        stream: getIt<ExpenseRemoteDataSource>()
                            .watchNetBalance(userId: uid, groupIds: groupIds),
                        builder: (ctx, snap) {
                          final s = snap.data ?? const BalanceSummary();
                          return BalanceSummaryCard(
                            netBalance: s.netBalance,
                            totalOwed: s.totalOwed,
                            totalOwe: s.totalOwe,
                            currency: currency,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Your Groups',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          BlocBuilder<GroupBloc, GroupState>(
            builder: (ctx, state) {
              if (state is GroupLoading || state is GroupOperationSuccess) {
                return const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue)),
                );
              }
              if (state is GroupError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(state.message,
                          style: const TextStyle(
                              color: AppTheme.error, fontSize: 13),
                          textAlign: TextAlign.center),
                    ),
                  ),
                );
              }
              if (state is GroupLoaded && state.groups.isEmpty) {
                return const SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_add_outlined,
                          size: 48, color: AppTheme.neutral300),
                      SizedBox(height: 14),
                      Text('No groups yet',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.neutral400)),
                      SizedBox(height: 6),
                      Text('Tap + to create your first group',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.neutral400)),
                    ],
                  ),
                );
              }
              if (state is GroupLoaded) {
                final hp = MediaQuery.of(ctx).size.width > 700
                    ? ((MediaQuery.of(ctx).size.width - 680) / 2)
                        .clamp(24.0, double.infinity)
                    : 16.0;
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(hp, 0, hp, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GroupCard(
                          group: state.groups[i],
                          onTap: () => ctx
                              .push(AppRoutes.groupDetail(state.groups[i].id)),
                        ),
                      ),
                      childCount: state.groups.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}

// ─── Activity Tab ─────────────────────────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final dynamic user;
  const _ActivityTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final uid = (user?.id as String?) ?? '';
    final w = MediaQuery.of(context).size.width;
    final hPad = w > 700 ? ((w - 680) / 2).clamp(24.0, double.infinity) : 16.0;

    return SafeArea(
      child: BlocBuilder<GroupBloc, GroupState>(
        builder: (ctx, gState) {
          final groups =
              gState is GroupLoaded ? gState.groups : <GroupEntity>[];
          final groupIds = groups.map((g) => g.id).toList();

          if (uid.isEmpty || groupIds.isEmpty) {
            return const _EmptyActivity();
          }

          return StreamBuilder<List<ExpenseEntity>>(
            stream: getIt<ExpenseRemoteDataSource>()
                .watchAllExpenses(groupIds: groupIds),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryBlue));
              }
              final expenses = snap.data ?? [];
              if (expenses.isEmpty) return const _EmptyActivity();

              // Group by date header
              final currency = (user?.defaultCurrency as String?) ?? 'INR';

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 12),
                      child: const Text('Recent Activity',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final e = expenses[i];
                          final groupName = groups
                                  .where((g) => g.id == e.groupId)
                                  .firstOrNull
                                  ?.name ??
                              '';
                          final paidByMe = e.paidBy == uid;
                          final myShare = e.splits
                              .where((s) => s.userId == uid)
                              .fold(0.0, (sum, s) => sum + s.amount);

                          return _ActivityTile(
                            expense: e,
                            groupName: groupName,
                            currency: currency,
                            paidByMe: paidByMe,
                            myShare: myShare,
                            uid: uid,
                          );
                        },
                        childCount: expenses.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ExpenseEntity expense;
  final String groupName;
  final String currency;
  final bool paidByMe;
  final double myShare;
  final String uid;

  const _ActivityTile({
    required this.expense,
    required this.groupName,
    required this.currency,
    required this.paidByMe,
    required this.myShare,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final isInvolved = myShare > 0.01;
    final amountText = CurrencyUtils.format(expense.amount, code: currency);
    final shareText = CurrencyUtils.format(myShare, code: currency);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          // Category emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: expense.category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(expense.category.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),

          // Title + group + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(groupName,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(_relativeDate(expense.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.neutral400)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Amount + your share
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountText,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              if (paidByMe)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('you paid',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.success,
                          fontWeight: FontWeight.w700)),
                )
              else if (isInvolved)
                Text('your share: $shareText',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600))
              else
                const Text('not involved',
                    style: TextStyle(fontSize: 11, color: AppTheme.neutral400)),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 44, color: AppTheme.neutral300),
          SizedBox(height: 12),
          Text('No activity yet',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral400)),
          SizedBox(height: 6),
          Text('Add expenses to a group\nto see activity here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.neutral400)),
        ],
      ),
    );
  }
}

// ─── Profile Tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final dynamic user;
  const _ProfileTab({required this.user});

  static const _currencies = [
    ('INR', '₹', 'Indian Rupee'),
    ('USD', '\$', 'US Dollar'),
    ('EUR', '€', 'Euro'),
    ('GBP', '£', 'British Pound'),
    ('JPY', '¥', 'Japanese Yen'),
    ('AED', 'د.إ', 'UAE Dirham'),
    ('SGD', 'S\$', 'Singapore Dollar'),
    ('CAD', 'CA\$', 'Canadian Dollar'),
    ('AUD', 'AU\$', 'Australian Dollar'),
    ('CHF', 'Fr', 'Swiss Franc'),
    ('CNY', '¥', 'Chinese Yuan'),
    ('MYR', 'RM', 'Malaysian Ringgit'),
    ('THB', '฿', 'Thai Baht'),
  ];

  Future<void> _pickCurrency(BuildContext ctx) async {
    final current = (user?.defaultCurrency as String?) ?? 'INR';
    await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        builder: (__, sc) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.neutral300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Default Currency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: sc,
                  children: _currencies.map((c) {
                    final sel = c.$1 == current;
                    return ListTile(
                      leading: Text(c.$2,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      title: Text('${c.$1} — ${c.$3}',
                          style: TextStyle(
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? AppTheme.primaryBlue : null)),
                      trailing: sel
                          ? const Icon(Icons.check,
                              color: AppTheme.primaryBlue, size: 18)
                          : null,
                      contentPadding: EdgeInsets.zero,
                      onTap: () async {
                        Navigator.of(bottomSheetContext).pop();
                        if (!sel && user != null) {
                          await getIt<AuthRemoteDataSource>().updateCurrency(
                            userId: user!.id as String,
                            currency: c.$1,
                          );
                          if (ctx.mounted) {
                            ctx.read<AuthBloc>().add(AuthCheckRequested());
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dCtx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(dCtx).pop();
              ctx.read<AuthBloc>().add(SignOutRequested());
            },
            child:
                const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 480) / 2).clamp(24.0, double.infinity) : 20.0;
    final currency = (user?.defaultCurrency as String?) ?? 'INR';

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                _Avatar(user: user, radius: isWide ? 38.0 : 32.0),
                const SizedBox(height: 10),
                Text((user?.name as String?) ?? '',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text((user?.email as String?) ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.neutral500)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _ProfileTile(
            icon: Icons.currency_exchange,
            label: 'Default Currency',
            subtitle: currency,
            onTap: () => _pickCurrency(context),
          ),
          // ── Theme toggle ────────────────────────────────────────
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (ctx, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.neutral700,
                  size: 20,
                ),
                title: const Text('Appearance',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  isDark ? 'Dark mode' : 'Light mode',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => toggleAppTheme(),
                  activeThumbColor: AppTheme.primaryBlue,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 1),
                onTap: toggleAppTheme,
              );
            },
          ),
          _ProfileTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {}),
          _ProfileTile(
              icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
          _ProfileTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () {}),
          const Divider(height: 28),
          _ProfileTile(
            icon: Icons.logout,
            label: 'Sign Out',
            color: AppTheme.error,
            onTap: () => _confirmSignOut(context),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('SplitEase v1.0',
                style: TextStyle(fontSize: 11, color: AppTheme.neutral400)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final dynamic user;
  final double radius;
  const _Avatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl as String?;
    final name = user?.name as String?;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
          radius: radius,
          backgroundImage: CachedNetworkImageProvider(photoUrl));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : '?',
        style: TextStyle(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryBlue),
      ),
    );
  }
}

// ─── Profile Tile ─────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.neutral700;
    return ListTile(
      leading: Icon(icon, color: c, size: 20),
      title: Text(label,
          style:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600))
          : null,
      trailing: color == null
          ? const Icon(Icons.chevron_right,
              color: AppTheme.neutral400, size: 18)
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 1),
      onTap: onTap,
    );
  }
}
