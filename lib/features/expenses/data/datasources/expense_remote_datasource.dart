import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

class BalanceSummary {
  final double netBalance;
  final double totalOwed;
  final double totalOwe;

  const BalanceSummary({
    this.netBalance = 0,
    this.totalOwed = 0,
    this.totalOwe = 0,
  });
}

abstract class ExpenseRemoteDataSource {
  Stream<List<ExpenseModel>> watchGroupExpenses(String groupId);

  Stream<BalanceSummary> watchNetBalance({
    required String userId,
    required List<String> groupIds,
  });

  /// Stream all expenses across multiple groups, newest first (max 50).
  Stream<List<ExpenseModel>> watchAllExpenses({
    required List<String> groupIds,
  });

  Future<ExpenseModel> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required SplitType splitType,
    required List<SplitShare> splits,
    required ExpenseCategory category,
    String? note,
  });
  Future<ExpenseModel> updateExpense({
    required String expenseId,
    String? title,
    double? amount,
    String? note,
    ExpenseCategory? category,
  });
  Future<void> deleteExpense(String expenseId);
  Future<ExpenseModel> getExpense(String expenseId);
  Future<String> uploadReceipt({
    required String expenseId,
    required String localPath,
  });
}

@LazySingleton(as: ExpenseRemoteDataSource)
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  ExpenseRemoteDataSourceImpl(this._db, this._storage);

  CollectionReference get _col => _db.collection(AppConstants.colExpenses);
  CollectionReference get _settlements =>
      _db.collection(AppConstants.colSettlements);

  // ── Watch group expenses ───────────────────────────────────────────────────
  @override
  Stream<List<ExpenseModel>> watchGroupExpenses(String groupId) {
    return _col.where('groupId', isEqualTo: groupId).snapshots().map((snap) {
      final list = snap.docs.map((d) => ExpenseModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ── Watch all expenses across groups (activity feed) ──────────────────────
  @override
  Stream<List<ExpenseModel>> watchAllExpenses({
    required List<String> groupIds,
  }) {
    if (groupIds.isEmpty) return Stream.value([]);
    final ids = groupIds.take(30).toList();
    return _col.where('groupId', whereIn: ids).snapshots().map((snap) {
      final list = snap.docs.map((d) => ExpenseModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.take(50).toList();
    });
  }

  // ── Watch net balance — expenses + settlements combined ───────────────────
  // Uses rxdart combineLatest2 so ANY write to either collection
  // (new expense, mark paid, etc.) instantly recalculates the card.
  @override
  Stream<BalanceSummary> watchNetBalance({
    required String userId,
    required List<String> groupIds,
  }) {
    if (groupIds.isEmpty) return Stream.value(const BalanceSummary());

    final ids = groupIds.take(30).toList();

    final expenseStream = _col.where('groupId', whereIn: ids).snapshots();
    final settlementStream =
        _settlements.where('groupId', whereIn: ids).snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, BalanceSummary>(
      expenseStream,
      settlementStream,
      (expSnap, settleSnap) {
        double owed = 0;
        double owe = 0;

        // 1. Tally raw expense splits
        for (final doc in expSnap.docs) {
          try {
            final e = ExpenseModel.fromFirestore(doc);
            if (e.paidBy == userId) {
              for (final s in e.splits) {
                if (s.userId != userId) owed += s.amount;
              }
            } else {
              for (final s in e.splits) {
                if (s.userId == userId) owe += s.amount;
              }
            }
          } catch (_) {}
        }

        // 2. Subtract settled amounts
        for (final doc in settleSnap.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final from = data['fromUserId'] as String? ?? '';
            final to = data['toUserId'] as String? ?? '';
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

            if (from == userId) owe = (owe - amount).clamp(0, double.infinity);
            if (to == userId) owed = (owed - amount).clamp(0, double.infinity);
          } catch (_) {}
        }

        return BalanceSummary(
          netBalance: owed - owe,
          totalOwed: owed,
          totalOwe: owe,
        );
      },
    );
  }

  // ── Add ────────────────────────────────────────────────────────────────────
  @override
  Future<ExpenseModel> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required SplitType splitType,
    required List<SplitShare> splits,
    required ExpenseCategory category,
    String? note,
  }) async {
    final id = _uuid.v4();
    final model = ExpenseModel(
      id: id,
      groupId: groupId,
      title: title,
      amount: amount,
      paidBy: paidBy,
      splitType: splitType,
      splits: splits,
      category: category,
      note: note,
      createdAt: DateTime.now(),
    );
    try {
      await _col.doc(id).set(model.toMap());
      // ignore: avoid_print
      print('✅ Expense saved: $id in group $groupId');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Expense save failed: $e');
      throw ExpenseException(e.toString());
    }
    return model;
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  @override
  Future<ExpenseModel> updateExpense({
    required String expenseId,
    String? title,
    double? amount,
    String? note,
    ExpenseCategory? category,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) data['title'] = title;
    if (amount != null) data['amount'] = amount;
    if (note != null) data['note'] = note;
    if (category != null) data['category'] = category.name;
    await _col.doc(expenseId).update(data);
    return getExpense(expenseId);
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  @override
  Future<void> deleteExpense(String expenseId) => _col.doc(expenseId).delete();

  // ── Get ────────────────────────────────────────────────────────────────────
  @override
  Future<ExpenseModel> getExpense(String expenseId) async {
    final doc = await _col.doc(expenseId).get();
    if (!doc.exists) throw const ExpenseException('Expense not found');
    return ExpenseModel.fromFirestore(doc);
  }

  // ── Upload receipt (mobile only) ───────────────────────────────────────────
  @override
  Future<String> uploadReceipt({
    required String expenseId,
    required String localPath,
  }) async {
    throw const StorageException(
      'Receipt upload is not supported on web. '
      'Use the mobile app to attach receipts.',
    );
  }
}
