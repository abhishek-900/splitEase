import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInWithGoogleUseCase {
  final AuthRepository _r;
  SignInWithGoogleUseCase(this._r);
  Future<Either<Failure, UserEntity>> call() => _r.signInWithGoogle();
}

@lazySingleton
class SignOutUseCase {
  final AuthRepository _r;
  SignOutUseCase(this._r);
  Future<Either<Failure, Unit>> call() => _r.signOut();
}

@lazySingleton
class GetCurrentUserUseCase {
  final AuthRepository _r;
  GetCurrentUserUseCase(this._r);
  Future<Either<Failure, UserEntity>> call() => _r.getCurrentUser();
}

@lazySingleton
class WatchAuthStateUseCase {
  final AuthRepository _r;
  WatchAuthStateUseCase(this._r);
  Stream<UserEntity?> call() => _r.authStateChanges;
}

@lazySingleton
class UpdateProfileUseCase {
  final AuthRepository _r;
  UpdateProfileUseCase(this._r);
  Future<Either<Failure, UserEntity>> call({
    required String userId,
    String? name,
    String? photoUrl,
  }) => _r.updateProfile(userId: userId, name: name, photoUrl: photoUrl);
}
