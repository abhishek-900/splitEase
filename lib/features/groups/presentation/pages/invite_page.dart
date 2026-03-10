import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/group_usecases.dart';

class InvitePage extends StatefulWidget {
  final String groupId;
  const InvitePage({super.key, required this.groupId});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage>
    with SingleTickerProviderStateMixin {
  GroupInvite? _invite;
  bool _loading = true;
  String? _error;
  bool _copied = false;
  late TabController _tabController;

  static const String _baseUrl = 'https://budgetrix-621fc.web.app';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _createInvite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createInvite() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final res = await getIt<CreateInviteUseCase>()(
      groupId: widget.groupId,
      createdBy: authState.user.id,
    );
    res.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (inv) => setState(() {
        _invite = inv;
        _loading = false;
      }),
    );
  }

  String get _inviteUrl => '$_baseUrl/join/${_invite?.id ?? ''}';

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _inviteUrl));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _shareLink() async {
    await Share.share(
      'Join "${_invite?.groupName ?? ''}" on SplitEase!\n\n$_inviteUrl\n\nExpires in 48 hours.',
      subject: 'Join my SplitEase group',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite People'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _createInvite,
            child: const Text(
              'New Link',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _createInvite)
              : _invite != null
                  ? _InviteBody(
                      invite: _invite!,
                      inviteUrl: _inviteUrl,
                      tabController: _tabController,
                      copied: _copied,
                      onCopy: _copyLink,
                      onShare: _shareLink,
                      onNewLink: _createInvite,
                    )
                  : const SizedBox.shrink(),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _InviteBody extends StatelessWidget {
  final GroupInvite invite;
  final String inviteUrl;
  final TabController tabController;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onNewLink;

  const _InviteBody({
    required this.invite,
    required this.inviteUrl,
    required this.tabController,
    required this.copied,
    required this.onCopy,
    required this.onShare,
    required this.onNewLink,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    final hPad = isWide ? ((w - 560) / 2).clamp(24.0, double.infinity) : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Text(
            'Invite to "${invite.groupName}"',
            style: TextStyle(
              fontSize: isWide ? 18.0 : 16.0,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Share the link or let them scan the QR code. Expires in 48 hours.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.neutral500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── Tab bar ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.neutral500,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.link, size: 15), text: 'Link'),
                Tab(icon: Icon(Icons.qr_code, size: 15), text: 'QR Code'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Tab views ────────────────────────────────────────────────
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: tabController,
              children: [
                _LinkTab(
                  inviteUrl: inviteUrl,
                  copied: copied,
                  onCopy: onCopy,
                  onShare: onShare,
                ),
                _QrTab(inviteUrl: inviteUrl),
              ],
            ),
          ),

          // ── Footer ───────────────────────────────────────────────────
          const Divider(height: 28),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: AppTheme.neutral400),
              const SizedBox(width: 5),
              const Text('Expires in 48 hours',
                  style: TextStyle(fontSize: 11, color: AppTheme.neutral400)),
              const Spacer(),
              GestureDetector(
                onTap: onNewLink,
                child: const Text(
                  'Generate new link',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Link tab ─────────────────────────────────────────────────────────────────

class _LinkTab extends StatelessWidget {
  final String inviteUrl;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _LinkTab({
    required this.inviteUrl,
    required this.copied,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.neutral200),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: AppTheme.primaryBlue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    inviteUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutral700,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Copy button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: copied
                ? SizedBox(
                    key: const ValueKey('copied'),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      icon: const Icon(Icons.check,
                          color: Colors.white, size: 15),
                      label: const Text('Copied!',
                          style: TextStyle(color: Colors.white)),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('copy'),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onCopy,
                      icon:
                          const Icon(Icons.copy, color: Colors.white, size: 15),
                      label: const Text('Copy Link'),
                    ),
                  ),
          ),
          const SizedBox(height: 8),

          // Share button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share,
                  color: AppTheme.primaryBlue, size: 15),
              label: const Text('Share via…'),
            ),
          ),
          const SizedBox(height: 12),

          // Info hint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anyone with this link can join. They open it in any browser and sign in — no app install needed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryBlue,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QR tab ───────────────────────────────────────────────────────────────────

class _QrTab extends StatelessWidget {
  final String inviteUrl;
  const _QrTab({required this.inviteUrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: inviteUrl,
                version: QrVersions.auto,
                size: 160,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppTheme.primaryBlue,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppTheme.neutral900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Scan with phone camera',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.neutral800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Opens directly in browser — no app needed',
            style: TextStyle(fontSize: 12, color: AppTheme.neutral400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_iphone, color: AppTheme.neutral500, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Works on iOS Safari, Android Chrome, and all modern browsers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutral500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.error),
            const SizedBox(height: 14),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.error, fontSize: 13)),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
