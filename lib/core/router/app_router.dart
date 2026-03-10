import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expense_detail_page.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/invite_page.dart';
import '../../features/groups/presentation/pages/join_group_page.dart';
import '../../features/settlements/presentation/pages/settle_up_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const createGroup = '/dashboard/groups/create';

  static String groupDetail(String id) => '/dashboard/groups/$id';
  static String groupInvite(String id) => '/dashboard/groups/$id/invite';
  static String addExpense(String groupId) =>
      '/dashboard/groups/$groupId/expenses/add';
  static String expenseDetail(String gId, String eId) =>
      '/dashboard/groups/$gId/expenses/$eId';
  static String settleUp(String groupId) => '/dashboard/groups/$groupId/settle';
  static String joinGroup(String inviteId) => '/join/$inviteId';
}

class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;
  _AuthNotifier(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── localStorage helpers ───────────────────────────────────────────────────────
// localStorage persists across page reloads and Firebase auth redirects.
// index.html ALSO writes this key before redirecting /join/:id → /#/join/:id
// so the invite is preserved even if routing temporarily loses the URL.
const _kPendingInvite = 'se_pending_invite';

void savePendingInvite(String inviteId) {
  try {
    web.window.localStorage.setItem(_kPendingInvite, inviteId);
  } catch (_) {}
}

String? consumePendingInvite() {
  try {
    final id = web.window.localStorage.getItem(_kPendingInvite);
    if (id != null && id.isNotEmpty) {
      web.window.localStorage.removeItem(_kPendingInvite);
      return id;
    }
  } catch (_) {}
  return null;
}

String? peekPendingInvite() {
  try {
    final id = web.window.localStorage.getItem(_kPendingInvite);
    if (id != null && id.isNotEmpty) return id;
  } catch (_) {}
  return null;
}

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    final notifier = _AuthNotifier(authBloc);

    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: notifier,
      redirect: (ctx, state) {
        final auth = authBloc.state;
        final loc = state.matchedLocation;
        final isJoin = loc.startsWith('/join/');
        final onAuth = loc == AppRoutes.splash || loc == AppRoutes.login;

        // ── RULE 1: Never redirect join pages ─────────────────────────────
        // Must be checked first, before any auth state logic.
        if (isJoin) return null;

        // ── RULE 2: Auth still resolving — only hold on splash ────────────
        if (auth is AuthLoading || auth is AuthInitial) {
          // If there's a pending invite and we're on splash/login,
          // stay here until auth resolves — don't send anywhere else yet
          return onAuth ? null : AppRoutes.splash;
        }

        // ── RULE 3: Authenticated ─────────────────────────────────────────
        if (auth is AuthAuthenticated) {
          // Check for a pending invite (set by index.html or join page
          // before a Firebase signInWithRedirect)
          final pending = consumePendingInvite();
          if (pending != null) return AppRoutes.joinGroup(pending);

          if (onAuth) return AppRoutes.dashboard;
          return null;
        }

        // ── RULE 4: Unauthenticated ───────────────────────────────────────
        if (auth is AuthUnauthenticated) {
          // If there's a pending invite, go to the join page
          // (not login — join page shows its own sign-in button)
          final pending = peekPendingInvite();
          if (pending != null) return AppRoutes.joinGroup(pending);

          // Redirect away from splash OR any protected page to login
          if (loc != AppRoutes.login) return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),

        // Public — join page handles auth inline
        GoRoute(
          path: '/join/:inviteId',
          builder: (_, s) => JoinGroupPage(
            inviteId: s.pathParameters['inviteId']!,
          ),
        ),

        GoRoute(
          path: AppRoutes.dashboard,
          builder: (_, __) => const DashboardPage(),
          routes: [
            GoRoute(
              path: 'groups/create',
              builder: (_, __) => const CreateGroupPage(),
            ),
            GoRoute(
              path: 'groups/:gid',
              builder: (_, s) =>
                  GroupDetailPage(groupId: s.pathParameters['gid']!),
              routes: [
                GoRoute(
                  path: 'invite',
                  builder: (_, s) =>
                      InvitePage(groupId: s.pathParameters['gid']!),
                ),
                GoRoute(
                  path: 'expenses/add',
                  builder: (_, s) =>
                      AddExpensePage(groupId: s.pathParameters['gid']!),
                ),
                GoRoute(
                  path: 'expenses/:eid',
                  builder: (_, s) => ExpenseDetailPage(
                    groupId: s.pathParameters['gid']!,
                    expenseId: s.pathParameters['eid']!,
                  ),
                ),
                GoRoute(
                  path: 'settle',
                  builder: (_, s) =>
                      SettleUpPage(groupId: s.pathParameters['gid']!),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
    );
  }
}
