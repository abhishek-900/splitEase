import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

@lazySingleton
class WatchGroupExpensesUseCase {
  final ExpenseRepository _r;
  WatchGroupExpensesUseCase(this._r);
  Stream<List<ExpenseEntity>> call(String groupId) => _r.watchGroupExpenses(groupId);
}

@lazySingleton
class AddExpenseUseCase {
  final ExpenseRepository _r;
  AddExpenseUseCase(this._r);
  Future<Either<Failure, ExpenseEntity>> call({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required SplitType splitType,
    required List<SplitShare> splits,
    required ExpenseCategory category,
    String? note,
  }) => _r.addExpense(
    groupId: groupId, title: title, amount: amount, paidBy: paidBy,
    splitType: splitType, splits: splits, category: category, note: note,
  );
}

@lazySingleton
class UpdateExpenseUseCase {
  final ExpenseRepository _r;
  UpdateExpenseUseCase(this._r);
  Future<Either<Failure, ExpenseEntity>> call({required String expenseId, String? title, double? amount, String? note, ExpenseCategory? category}) =>
      _r.updateExpense(expenseId: expenseId, title: title, amount: amount, note: note, category: category);
}

@lazySingleton
class DeleteExpenseUseCase {
  final ExpenseRepository _r;
  DeleteExpenseUseCase(this._r);
  Future<Either<Failure, Unit>> call(String id) => _r.deleteExpense(id);
}

@lazySingleton
class GetExpenseUseCase {
  final ExpenseRepository _r;
  GetExpenseUseCase(this._r);
  Future<Either<Failure, ExpenseEntity>> call(String id) => _r.getExpense(id);
}

@lazySingleton
class UploadReceiptUseCase {
  final ExpenseRepository _r;
  UploadReceiptUseCase(this._r);
  Future<Either<Failure, String>> call({required String expenseId, required String localPath}) =>
      _r.uploadReceipt(expenseId: expenseId, localPath: localPath);
}
