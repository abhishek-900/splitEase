import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final NetworkInfo          _net;

  AuthRepositoryImpl(this._remote, this._net);

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!await _net.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.signInWithGoogle());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      return Right(await _remote.getCurrentUser());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    if (!await _net.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.updateProfile(userId: userId, name: name, photoUrl: photoUrl));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
