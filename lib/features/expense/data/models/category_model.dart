import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return CategoryModel(
      id: json['id'] ?? fallbackId ?? '',
      name: json['name'] ?? 'Unknown',
      icon: json['icon'] ?? 'help',
      color: json['color'] ?? '0xFF9E9E9E',
      type: json['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
    );
  }
}
