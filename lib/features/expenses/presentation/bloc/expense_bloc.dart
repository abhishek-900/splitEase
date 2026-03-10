import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/expense_usecases.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroupExpenses extends ExpenseEvent {
  final String groupId;
  const LoadGroupExpenses(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class AddExpense extends ExpenseEvent {
  final String groupId;
  final String title;
  final double amount;
  final String paidBy;
  final SplitType splitType;
  final List<SplitShare> splits;
  final ExpenseCategory category;
  final String? note;

  const AddExpense({
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
    required this.category,
    this.note,
  });

  @override
  List<Object?> get props =>
      [groupId, title, amount, paidBy, splitType, category];
}

class UpdateExpense extends ExpenseEvent {
  final String expenseId;
  final String? title;
  final double? amount;
  final String? note;
  final ExpenseCategory? category;

  const UpdateExpense({
    required this.expenseId,
    this.title,
    this.amount,
    this.note,
    this.category,
  });
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;
  final String groupId;
  const DeleteExpense({required this.expenseId, required this.groupId});
  @override
  List<Object?> get props => [expenseId, groupId];
}

class _ExpensesChanged extends ExpenseEvent {
  final List<ExpenseEntity> expenses;
  const _ExpensesChanged(this.expenses);
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  const ExpenseLoaded(this.expenses);
  @override
  List<Object?> get props => [expenses];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  const ExpenseOperationSuccess({this.message = 'Success'});
  @override
  List<Object?> get props => [message];
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

@injectable
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final WatchGroupExpensesUseCase _watch;
  final AddExpenseUseCase _add;
  final UpdateExpenseUseCase _update;
  final DeleteExpenseUseCase _delete;

  StreamSubscription<List<ExpenseEntity>>? _sub;
  String? _currentGroupId;

  ExpenseBloc(this._watch, this._add, this._update, this._delete)
      : super(ExpenseInitial()) {
    on<LoadGroupExpenses>(_onLoad);
    on<_ExpensesChanged>(_onChanged);
    on<AddExpense>(_onAdd);
    on<UpdateExpense>(_onUpdate);
    on<DeleteExpense>(_onDelete);
  }

  // ── Load / watch ───────────────────────────────────────────────────────────
  Future<void> _onLoad(LoadGroupExpenses e, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    _currentGroupId = e.groupId;
    await _sub?.cancel();
    _sub = _watch(e.groupId).listen(
      (expenses) => add(_ExpensesChanged(expenses)),
      onError: (_) => add(const _ExpensesChanged([])),
    );
  }

  void _onChanged(_ExpensesChanged e, Emitter<ExpenseState> emit) {
    emit(ExpenseLoaded(e.expenses));
  }

  // ── Add ────────────────────────────────────────────────────────────────────
  Future<void> _onAdd(AddExpense e, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final res = await _add(
      groupId: e.groupId,
      title: e.title,
      amount: e.amount,
      paidBy: e.paidBy,
      splitType: e.splitType,
      splits: e.splits,
      category: e.category,
      note: e.note,
    );
    res.fold(
      (f) => emit(ExpenseError(f.message)),
      (_) {
        emit(const ExpenseOperationSuccess(message: 'Expense added'));
        // Re-subscribe so the list updates immediately
        if (_currentGroupId != null) {
          add(LoadGroupExpenses(_currentGroupId!));
        }
      },
    );
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> _onUpdate(UpdateExpense e, Emitter<ExpenseState> emit) async {
    final res = await _update(
      expenseId: e.expenseId,
      title: e.title,
      amount: e.amount,
      note: e.note,
      category: e.category,
    );
    res.fold(
      (f) => emit(ExpenseError(f.message)),
      (_) => emit(const ExpenseOperationSuccess(message: 'Expense updated')),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> _onDelete(DeleteExpense e, Emitter<ExpenseState> emit) async {
    final res = await _delete(e.expenseId);
    res.fold(
      (f) => emit(ExpenseError(f.message)),
      (_) {
        emit(const ExpenseOperationSuccess(message: 'Expense deleted'));
        if (_currentGroupId != null) {
          add(LoadGroupExpenses(_currentGroupId!));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
