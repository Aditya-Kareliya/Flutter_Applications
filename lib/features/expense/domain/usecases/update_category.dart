import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class UpdateCategory {
  final ExpenseRepository repository;

  UpdateCategory(this.repository);

  Future<void> call(Category category) async {
    return await repository.updateCategory(category);
  }
}
