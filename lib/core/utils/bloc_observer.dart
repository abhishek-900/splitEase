import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  final _log = Logger();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _log.e('[${bloc.runtimeType}] error', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    _log.d(
        '[${bloc.runtimeType}] ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}');
    super.onTransition(bloc, transition);
  }
}
