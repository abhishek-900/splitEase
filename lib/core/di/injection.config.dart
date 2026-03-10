// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:splitease/core/network/network_info.dart' as _i355;
import 'package:splitease/core/services/notification_service.dart' as _i682;
import 'package:splitease/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i989;
import 'package:splitease/features/auth/data/repositories/auth_repository_impl.dart'
    as _i242;
import 'package:splitease/features/auth/domain/repositories/auth_repository.dart'
    as _i307;
import 'package:splitease/features/auth/domain/usecases/auth_usecases.dart'
    as _i294;
import 'package:splitease/features/auth/presentation/bloc/auth_bloc.dart'
    as _i457;
import 'package:splitease/features/expenses/data/datasources/expense_remote_datasource.dart'
    as _i99;
import 'package:splitease/features/expenses/data/repositories/expense_repository_impl.dart'
    as _i1067;
import 'package:splitease/features/expenses/domain/repositories/expense_repository.dart'
    as _i74;
import 'package:splitease/features/expenses/domain/usecases/expense_usecases.dart'
    as _i556;
import 'package:splitease/features/expenses/presentation/bloc/expense_bloc.dart'
    as _i345;
import 'package:splitease/features/groups/data/datasources/group_remote_datasource.dart'
    as _i107;
import 'package:splitease/features/groups/data/repositories/group_repository_impl.dart'
    as _i962;
import 'package:splitease/features/groups/domain/repositories/group_repository.dart'
    as _i651;
import 'package:splitease/features/groups/domain/usecases/group_usecases.dart'
    as _i89;
import 'package:splitease/features/groups/presentation/bloc/group_bloc.dart'
    as _i40;
import 'package:splitease/features/settlements/data/datasources/settlement_remote_datasource.dart'
    as _i532;
import 'package:splitease/features/settlements/data/repositories/settlement_repository_impl.dart'
    as _i967;
import 'package:splitease/features/settlements/domain/repositories/settlement_repository.dart'
    as _i158;
import 'package:splitease/features/settlements/domain/usecases/settlement_usecases.dart'
    as _i1006;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i989.AuthRemoteDataSource>(
        () => _i989.AuthRemoteDataSourceImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i974.FirebaseFirestore>(),
              gh<_i116.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i532.SettlementRemoteDataSource>(() =>
        _i532.SettlementRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i355.NetworkInfo>(
        () => _i355.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i682.NotificationService>(() => _i682.NotificationService(
          gh<_i892.FirebaseMessaging>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i107.GroupRemoteDataSource>(
        () => _i107.GroupRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i158.SettlementRepository>(
        () => _i967.SettlementRepositoryImpl(
              gh<_i532.SettlementRemoteDataSource>(),
              gh<_i355.NetworkInfo>(),
            ));
    gh.lazySingleton<_i651.GroupRepository>(() => _i962.GroupRepositoryImpl(
          gh<_i107.GroupRemoteDataSource>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i99.ExpenseRemoteDataSource>(
        () => _i99.ExpenseRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i307.AuthRepository>(() => _i242.AuthRepositoryImpl(
          gh<_i989.AuthRemoteDataSource>(),
          gh<_i355.NetworkInfo>(),
        ));
    gh.lazySingleton<_i294.SignInWithGoogleUseCase>(
        () => _i294.SignInWithGoogleUseCase(gh<_i307.AuthRepository>()));
    gh.lazySingleton<_i294.SignOutUseCase>(
        () => _i294.SignOutUseCase(gh<_i307.AuthRepository>()));
    gh.lazySingleton<_i294.GetCurrentUserUseCase>(
        () => _i294.GetCurrentUserUseCase(gh<_i307.AuthRepository>()));
    gh.lazySingleton<_i294.WatchAuthStateUseCase>(
        () => _i294.WatchAuthStateUseCase(gh<_i307.AuthRepository>()));
    gh.lazySingleton<_i294.UpdateProfileUseCase>(
        () => _i294.UpdateProfileUseCase(gh<_i307.AuthRepository>()));
    gh.lazySingleton<_i89.WatchUserGroupsUseCase>(
        () => _i89.WatchUserGroupsUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.CreateGroupUseCase>(
        () => _i89.CreateGroupUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.GetGroupUseCase>(
        () => _i89.GetGroupUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.UpdateGroupUseCase>(
        () => _i89.UpdateGroupUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.DeleteGroupUseCase>(
        () => _i89.DeleteGroupUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.AddMemberUseCase>(
        () => _i89.AddMemberUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.RemoveMemberUseCase>(
        () => _i89.RemoveMemberUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.CreateInviteUseCase>(
        () => _i89.CreateInviteUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.JoinViaInviteUseCase>(
        () => _i89.JoinViaInviteUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i89.GetGroupBalancesUseCase>(
        () => _i89.GetGroupBalancesUseCase(gh<_i651.GroupRepository>()));
    gh.lazySingleton<_i1006.WatchGroupSettlementsUseCase>(() =>
        _i1006.WatchGroupSettlementsUseCase(gh<_i158.SettlementRepository>()));
    gh.lazySingleton<_i1006.RecordSettlementUseCase>(
        () => _i1006.RecordSettlementUseCase(gh<_i158.SettlementRepository>()));
    gh.factory<_i457.AuthBloc>(() => _i457.AuthBloc(
          gh<_i294.SignInWithGoogleUseCase>(),
          gh<_i294.SignOutUseCase>(),
          gh<_i294.WatchAuthStateUseCase>(),
        ));
    gh.factory<_i40.GroupBloc>(() => _i40.GroupBloc(
          gh<_i89.WatchUserGroupsUseCase>(),
          gh<_i89.CreateGroupUseCase>(),
          gh<_i89.UpdateGroupUseCase>(),
          gh<_i89.DeleteGroupUseCase>(),
          gh<_i89.RemoveMemberUseCase>(),
        ));
    gh.lazySingleton<_i74.ExpenseRepository>(() => _i1067.ExpenseRepositoryImpl(
          gh<_i99.ExpenseRemoteDataSource>(),
          gh<_i355.NetworkInfo>(),
        ));
    gh.lazySingleton<_i556.WatchGroupExpensesUseCase>(
        () => _i556.WatchGroupExpensesUseCase(gh<_i74.ExpenseRepository>()));
    gh.lazySingleton<_i556.AddExpenseUseCase>(
        () => _i556.AddExpenseUseCase(gh<_i74.ExpenseRepository>()));
    gh.lazySingleton<_i556.UpdateExpenseUseCase>(
        () => _i556.UpdateExpenseUseCase(gh<_i74.ExpenseRepository>()));
    gh.lazySingleton<_i556.DeleteExpenseUseCase>(
        () => _i556.DeleteExpenseUseCase(gh<_i74.ExpenseRepository>()));
    gh.lazySingleton<_i556.GetExpenseUseCase>(
        () => _i556.GetExpenseUseCase(gh<_i74.ExpenseRepository>()));
    gh.lazySingleton<_i556.UploadReceiptUseCase>(
        () => _i556.UploadReceiptUseCase(gh<_i74.ExpenseRepository>()));
    gh.factory<_i345.ExpenseBloc>(() => _i345.ExpenseBloc(
          gh<_i556.WatchGroupExpensesUseCase>(),
          gh<_i556.AddExpenseUseCase>(),
          gh<_i556.UpdateExpenseUseCase>(),
          gh<_i556.DeleteExpenseUseCase>(),
        ));
    return this;
  }
}
