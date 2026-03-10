import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String defaultCurrency;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.defaultCurrency = 'INR',
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, email, photoUrl, defaultCurrency, createdAt];
}
