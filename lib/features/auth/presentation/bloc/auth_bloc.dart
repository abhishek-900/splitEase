import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}

class AuthCheckRequested    extends AuthEvent {}
class GoogleSignInRequested extends AuthEvent {}
class SignOutRequested       extends AuthEvent {}

class _UserChanged extends AuthEvent {
  final UserEntity? user;
  const _UserChanged(this.user);
  @override List<Object?> get props => [user];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial        extends AuthState {}
class AuthLoading        extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase _signIn;
  final SignOutUseCase          _signOut;
  final WatchAuthStateUseCase   _watch;

  StreamSubscription<UserEntity?>? _sub;

  AuthBloc(this._signIn, this._signOut, this._watch) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<_UserChanged>(_onUserChanged);
    on<GoogleSignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _sub?.cancel();
    _sub = _watch().listen((u) => add(_UserChanged(u)));
  }

  void _onUserChanged(_UserChanged e, Emitter<AuthState> emit) {
    e.user != null ? emit(AuthAuthenticated(e.user!)) : emit(AuthUnauthenticated());
  }

  Future<void> _onSignIn(GoogleSignInRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _signIn();
    res.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }

  Future<void> _onSignOut(SignOutRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _signOut();
    res.fold((f) => emit(AuthError(f.message)), (_) => emit(AuthUnauthenticated()));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
