import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/bloc_observer.dart';
import 'core/utils/local_storage.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/groups/presentation/bloc/group_bloc.dart';
import 'firebase_options.dart';

const _kThemeKey = 'se_theme_mode';

/// Global notifier — any widget can listen to theme changes without
/// needing findAncestorStateOfType (which doesn't register a dependency).
final themeNotifier = ValueNotifier<ThemeMode>(
  LocalStorage.read(_kThemeKey) == 'dark' ? ThemeMode.dark : ThemeMode.light,
);

void toggleAppTheme() {
  final next =
      themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  LocalStorage.write(_kThemeKey, next == ThemeMode.dark ? 'dark' : 'light');
  themeNotifier.value = next;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(const SplitEaseApp());
}

class SplitEaseApp extends StatefulWidget {
  const SplitEaseApp({super.key});

  @override
  State<SplitEaseApp> createState() => _SplitEaseAppState();
}

class _SplitEaseAppState extends State<SplitEaseApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(AuthCheckRequested());
    _router = AppRouter.createRouter(_authBloc);
    themeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<GroupBloc>(create: (_) => getIt<GroupBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, __) => MaterialApp.router(
          title: 'SplitEase',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeNotifier.value,
          routerConfig: _router,
        ),
      ),
    );
  }
}
