import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/group_usecases.dart';
import '../../presentation/bloc/group_bloc.dart';

void _log(String msg) {
  logger.debug('🔍 [JoinGroupPage] $msg');
}

class JoinGroupPage extends StatefulWidget {
  final String inviteId;
  const JoinGroupPage({super.key, required this.inviteId});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  _ViewState _viewState = _ViewState.loading;
  String? _error;
  String? _groupId;
  String? _groupName;

  @override
  void initState() {
    super.initState();
    _log('initState — inviteId: ${widget.inviteId}');
    _checkAuthAndJoin();
  }

  Future<void> _checkAuthAndJoin() async {
    _log('_checkAuthAndJoin start');
    final authBloc = context.read<AuthBloc>();
    var auth = authBloc.state;
    _log('initial auth state: ${auth.runtimeType}');

    if (auth is AuthInitial) {
      _log('dispatching AuthCheckRequested');
      authBloc.add(AuthCheckRequested());
    }

    if (auth is AuthInitial || auth is AuthLoading) {
      _log('waiting for auth to resolve...');
      await for (final s in authBloc.stream) {
        _log('auth stream event: ${s.runtimeType}');
        if (!mounted) return;
        auth = s;
        if (s is AuthAuthenticated || s is AuthUnauthenticated) break;
      }
    }

    if (!mounted) return;
    _log('auth resolved: ${auth.runtimeType}');

    if (auth is AuthAuthenticated) {
      _log('user authenticated: ${(auth).user.id}');
      await _doJoin(auth.user.id);
    } else {
      _log('user not authenticated — showing sign-in');
      setState(() => _viewState = _ViewState.needsSignIn);
    }
  }

  Future<void> _signInAndJoin() async {
    _log('_signInAndJoin — saving pending invite');
    setState(() {
      _viewState = _ViewState.loading;
      _error = null;
    });

    savePendingInvite(widget.inviteId);

    final authBloc = context.read<AuthBloc>();
    authBloc.add(GoogleSignInRequested());
    _log('GoogleSignInRequested dispatched');

    await for (final s in authBloc.stream) {
      _log('sign-in stream event: ${s.runtimeType}');
      if (!mounted) return;

      if (s is AuthAuthenticated) {
        _log('sign-in success: ${s.user.id}');
        consumePendingInvite();
        await _doJoin(s.user.id);
        return;
      }

      if (s is AuthError) {
        _log('sign-in error: ${s.message}');
        if (s.message == 'redirect_initiated') return;
        consumePendingInvite();
        setState(() {
          _viewState = _ViewState.error;
          _error = s.message;
        });
        return;
      }

      if (s is AuthUnauthenticated) {
        _log('sign-in cancelled');
        consumePendingInvite();
        setState(() {
          _viewState = _ViewState.error;
          _error = 'Sign-in was cancelled.';
        });
        return;
      }
    }
  }

  Future<void> _doJoin(String uid) async {
    _log('_doJoin start — uid: $uid, inviteId: ${widget.inviteId}');
    if (!mounted) return;
    setState(() {
      _viewState = _ViewState.loading;
      _error = null;
    });

    _log('calling JoinViaInviteUseCase...');
    final res = await getIt<JoinViaInviteUseCase>()(
      inviteId: widget.inviteId,
      userId: uid,
    );
    _log('JoinViaInviteUseCase returned');

    if (!mounted) return;

    res.fold(
      (f) {
        _log('join FAILED: ${f.runtimeType} — ${f.message}');
        setState(() {
          _viewState = _ViewState.error;
          _error = f.message;
        });
      },
      (group) {
        _log('join SUCCESS — group: ${group.id} "${group.name}"');
        setState(() {
          _viewState = _ViewState.success;
          _groupId = group.id;
          _groupName = group.name;
        });
        context.read<GroupBloc>().add(LoadUserGroups(uid));
      },
    );
  }

  Future<void> _retry() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      await _doJoin(auth.user.id);
    } else {
      setState(() => _viewState = _ViewState.needsSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final hPad = w > 600 ? ((w - 400) / 2).clamp(32.0, double.infinity) : 32.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
            child: switch (_viewState) {
              _ViewState.loading => const _LoadingView(),
              _ViewState.needsSignIn => _SignInView(onSignIn: _signInAndJoin),
              _ViewState.success => _SuccessView(
                  groupName: _groupName ?? 'the group',
                  onGoToGroup: () =>
                      context.go(AppRoutes.groupDetail(_groupId!)),
                  onGoHome: () => context.go(AppRoutes.dashboard),
                ),
              _ViewState.error => _ErrorView(
                  error: _error ?? 'Something went wrong',
                  onRetry: _retry,
                  onHome: () => context.go(AppRoutes.dashboard),
                ),
            },
          ),
        ),
      ),
    );
  }
}

enum _ViewState { loading, needsSignIn, success, error }

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
              child: Text('SE',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))),
        ),
        const SizedBox(height: 28),
        const Text('Joining group…',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Please wait…',
            style: TextStyle(fontSize: 13, color: AppTheme.neutral500)),
        const SizedBox(height: 32),
        const CircularProgressIndicator(color: AppTheme.primaryBlue),
      ],
    );
  }
}

class _SignInView extends StatelessWidget {
  final VoidCallback onSignIn;
  const _SignInView({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
              child: Text('SE',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))),
        ),
        const SizedBox(height: 28),
        const Text("You've been invited!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Sign in with Google to join the group.\nNo app install needed.',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 13, color: AppTheme.neutral500, height: 1.5),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSignIn,
            icon: const Icon(Icons.login, color: Colors.white, size: 18),
            label: const Text('Sign in with Google'),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'You may be redirected to Google\nand brought back automatically.',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 11, color: AppTheme.neutral400, height: 1.5),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String groupName;
  final VoidCallback onGoToGroup;
  final VoidCallback onGoHome;
  const _SuccessView(
      {required this.groupName,
      required this.onGoToGroup,
      required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppTheme.success, size: 44),
        ),
        const SizedBox(height: 24),
        const Text("You're in! 🎉",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('You have joined',
            style: TextStyle(fontSize: 14, color: AppTheme.neutral500)),
        const SizedBox(height: 4),
        Text(groupName,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue),
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onGoToGroup,
            icon: const Icon(Icons.group, color: Colors.white, size: 16),
            label: const Text('Go to Group'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onGoHome,
            child: const Text('Go to Dashboard'),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  const _ErrorView(
      {required this.error, required this.onRetry, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final isExpired = error.toLowerCase().contains('expir');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isExpired ? Icons.schedule : Icons.error_outline,
            color: AppTheme.error,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(isExpired ? 'Invite Expired' : "Couldn't Join",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          isExpired
              ? 'This invite link has expired.\nAsk the group admin for a new one.'
              : error,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppTheme.neutral500),
        ),
        const SizedBox(height: 32),
        if (!isExpired) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: onRetry, child: const Text('Try Again')),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: onHome, child: const Text('Go to Dashboard')),
        ),
      ],
    );
  }
}
