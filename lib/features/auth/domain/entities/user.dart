import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;

  final String? currency;
  final String? themeMode;
  final String? themeColor;

  const User({required this.id, required this.email, required this.name, this.currency, this.themeMode, this.themeColor});

  @override
  List<Object?> get props => [id, email, name, currency, themeMode, themeColor];
}
