import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/group_usecases.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class GroupEvent extends Equatable {
  const GroupEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserGroups extends GroupEvent {
  final String userId;
  const LoadUserGroups(this.userId);
  @override
  List<Object?> get props => [userId];
}

class CreateGroup extends GroupEvent {
  final String name;
  final String createdBy;
  final String? imageUrl;
  final String currency;
  const CreateGroup({
    required this.name,
    required this.createdBy,
    this.imageUrl,
    this.currency = 'USD',
  });
  @override
  List<Object?> get props => [name, createdBy, currency];
}

class UpdateGroup extends GroupEvent {
  final String groupId;
  final String? name;
  final String? imageUrl;
  final String? currency;
  const UpdateGroup(
      {required this.groupId, this.name, this.imageUrl, this.currency});
}

class DeleteGroup extends GroupEvent {
  final String groupId;
  const DeleteGroup(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class RemoveMember extends GroupEvent {
  final String groupId;
  final String userId;
  const RemoveMember({required this.groupId, required this.userId});
}

class _GroupsChanged extends GroupEvent {
  final List<GroupEntity> groups;
  const _GroupsChanged(this.groups);
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class GroupState extends Equatable {
  const GroupState();
  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final List<GroupEntity> groups;
  const GroupLoaded(this.groups);
  @override
  List<Object?> get props => [groups];
}

class GroupOperationSuccess extends GroupState {
  final GroupEntity? group;
  final String message;
  const GroupOperationSuccess({this.group, this.message = 'Success'});
  @override
  List<Object?> get props => [group, message];
}

class GroupError extends GroupState {
  final String message;
  const GroupError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

@injectable
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final WatchUserGroupsUseCase _watch;
  final CreateGroupUseCase _create;
  final UpdateGroupUseCase _update;
  final DeleteGroupUseCase _delete;
  final RemoveMemberUseCase _remove;

  StreamSubscription<List<GroupEntity>>? _sub;

  GroupBloc(this._watch, this._create, this._update, this._delete, this._remove)
      : super(GroupInitial()) {
    on<LoadUserGroups>(_onLoad);
    on<_GroupsChanged>(_onChanged);
    on<CreateGroup>(_onCreate);
    on<UpdateGroup>(_onUpdate);
    on<DeleteGroup>(_onDelete);
    on<RemoveMember>(_onRemove);
  }

  Future<void> _onLoad(LoadUserGroups e, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    await _sub?.cancel();
    _sub = _watch(e.userId).listen(
      (groups) => add(_GroupsChanged(groups)),
      onError: (err) {
        // emit error so UI shows something useful
        add(const _GroupsChanged([]));
      },
    );
  }

  void _onChanged(_GroupsChanged e, Emitter<GroupState> emit) {
    emit(GroupLoaded(e.groups));
  }

  Future<void> _onCreate(CreateGroup e, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    final res = await _create(
      name: e.name,
      createdBy: e.createdBy,
      imageUrl: e.imageUrl,
      currency: e.currency,
    );
    res.fold(
      (f) => emit(GroupError(f.message)),
      (g) {
        emit(GroupOperationSuccess(group: g, message: 'Group created'));
        // Re-subscribe so the stream fires GroupLoaded immediately
        add(LoadUserGroups(e.createdBy));
      },
    );
  }

  Future<void> _onUpdate(UpdateGroup e, Emitter<GroupState> emit) async {
    final res = await _update(
      groupId: e.groupId,
      name: e.name,
      imageUrl: e.imageUrl,
      currency: e.currency,
    );
    res.fold(
      (f) => emit(GroupError(f.message)),
      (g) => emit(GroupOperationSuccess(group: g, message: 'Group updated')),
    );
  }

  Future<void> _onDelete(DeleteGroup e, Emitter<GroupState> emit) async {
    final res = await _delete(e.groupId);
    res.fold(
      (f) => emit(GroupError(f.message)),
      (_) => emit(const GroupOperationSuccess(message: 'Group deleted')),
    );
  }

  Future<void> _onRemove(RemoveMember e, Emitter<GroupState> emit) async {
    final res = await _remove(groupId: e.groupId, userId: e.userId);
    res.fold((f) => emit(GroupError(f.message)), (_) => null);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
