import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseEntity>> watchGroupExpenses(String groupId);
  Future<Either<Failure, ExpenseEntity>> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required SplitType splitType,
    required List<SplitShare> splits,
    required ExpenseCategory category,
    String? note,
  });
  Future<Either<Failure, ExpenseEntity>>  updateExpense({required String expenseId, String? title, double? amount, String? note, ExpenseCategory? category});
  Future<Either<Failure, Unit>>            deleteExpense(String expenseId);
  Future<Either<Failure, ExpenseEntity>>  getExpense(String expenseId);
  Future<Either<Failure, String>>          uploadReceipt({required String expenseId, required String localPath});
}
