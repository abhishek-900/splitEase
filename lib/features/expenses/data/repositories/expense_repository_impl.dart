import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

@LazySingleton(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remote;
  final NetworkInfo             _net;

  ExpenseRepositoryImpl(this._remote, this._net);

  @override
  Stream<List<ExpenseEntity>> watchGroupExpenses(String groupId) =>
      _remote.watchGroupExpenses(groupId);

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense({
    required String groupId, required String title, required double amount,
    required String paidBy, required SplitType splitType,
    required List<SplitShare> splits, required ExpenseCategory category, String? note,
  }) async {
    if (!await _net.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.addExpense(
        groupId: groupId, title: title, amount: amount, paidBy: paidBy,
        splitType: splitType, splits: splits, category: category, note: note,
      ));
    } on ExpenseException catch (e) {
      return Left(ExpenseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> updateExpense({required String expenseId, String? title, double? amount, String? note, ExpenseCategory? category}) async {
    if (!await _net.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.updateExpense(expenseId: expenseId, title: title, amount: amount, note: note, category: category));
    } on ExpenseException catch (e) {
      return Left(ExpenseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(String expenseId) async {
    try {
      await _remote.deleteExpense(expenseId);
      return const Right(unit);
    } on ExpenseException catch (e) {
      return Left(ExpenseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> getExpense(String expenseId) async {
    try {
      return Right(await _remote.getExpense(expenseId));
    } on ExpenseException catch (e) {
      return Left(ExpenseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadReceipt({required String expenseId, required String localPath}) async {
    if (!await _net.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await _remote.uploadReceipt(expenseId: expenseId, localPath: localPath));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}
