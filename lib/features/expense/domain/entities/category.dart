import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon; // IconData codepoint or name
  final String color; // Hex string e.g. 0xFF...
  final String type; // 'expense' or 'income'

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  String get displayName => name;

  @override
  List<Object?> get props => [id, name, icon, color, type];
}
