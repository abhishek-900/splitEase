import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class ServerFailure   extends Failure { const ServerFailure([super.message   = 'Server error.']); }
class NetworkFailure  extends Failure { const NetworkFailure([super.message  = 'No internet connection.']); }
class CacheFailure    extends Failure { const CacheFailure([super.message    = 'Cache error.']); }
class AuthFailure     extends Failure { const AuthFailure([super.message     = 'Authentication failed.']); }
class GroupFailure    extends Failure { const GroupFailure([super.message    = 'Group error.']); }
class ExpenseFailure  extends Failure { const ExpenseFailure([super.message  = 'Expense error.']); }
class SettleFailure   extends Failure { const SettleFailure([super.message   = 'Settlement error.']); }
class InviteFailure   extends Failure { const InviteFailure([super.message   = 'Invalid invite.']); }
class StorageFailure  extends Failure { const StorageFailure([super.message  = 'Upload failed.']); }
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
